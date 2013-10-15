--- Communications library for interfacing with BTSync
-- @module btcomm
-- @author Conor Heine
-- @license MIT
-- @copyright Conor Heine 2013

local http  = require 'socket.http'
local ltn12 = require 'ltn12'
local json  = require 'cjson'
local mime  = require 'mime'
local d     = require 'pl.pretty'.dump

local btcomm = {}

--- Private functions.
-- @section Private

--- Takes a table of key-value pairs and formats it to GET request param string
-- @table[opt] p Table of key-value pairs describing GET params as: param = value 
local function param_string(p)
  if p == nil or #p < 1 then 
    print('EMPTY PARAMS')
    return '' 
  end

  local pstr = '?'
  local i = 0

  for param, val in pairs(p) do
    pstr = pstr .. param .. '=' .. val
    if i < #p - 1 then
      pstr = pstr .. '&'
    end
    i = i + 1
  end

  return pstr
end

--- Takes set-cookie string and parses it into a table
-- @string set_cookie set-cookie string from response headers
local function explode_cookie(set_cookie)
  local c = {}
  
  set_cookie = set_cookie .. ' ' -- make gmatch play nice

  for cookie_name, cookie_val in set_cookie:gmatch("(.-)=(.-);? ") do
    c[cookie_name] = cookie_val
  end

  return c
end

--- Format table of cookie = value key-value-pairs and formats them
-- into a cookie string for a request header
-- @table cookies Table of cookies with pairs in the form cookie_name = value
local function implode_cookies(cookies)
  local c = ''

  for name, val in pairs(cookies) do
    c = c .. name .. '=' .. val .. '; '
  end

  return c:gsub('; $', '')
end

--- Properly formats a request URL for the given path and optional GET parameters
-- based on loaded btsync config
function btcomm:url(path, params)
  return ('%s://%s:%d/gui/%s%s'):format(self.scheme, self.host, self.port, path, param_string(params))
end

--- Performs http request and return sane response data (wrapper for http.request)
function btcomm:request(r)
  local response = {}
  local save     = ltn12.sink.table(response)
  local headers  = r.headers or {}

  if self.use_auth then
    headers.Authorization = "Basic " .. (mime.b64(self.user .. ":" .. self.pass))
  end

  if self.session.cookie then
    headers.Cookie = implode_cookies(self.session.cookie)
  end

  headers.Connection = 'keep-alive'

  local q = { 
    url     = self:url(r.url or '', r.params),
    sink    = save,
    headers = headers,
    method  = r.method  or 'GET',
    redirect = false
  }
d(q)
  local ok, code, headers = http.request(q)

  if not ok then 
    error('Failed request') 
  else
    if headers['set-cookie'] then
      if not self.session.cookie then
        self.session.cookie = {}
      end

      self.session.cookie = explode_cookie(headers['set-cookie'])
      d(self.session.cookie)
    end
  end

  return code, headers, response[1]
end

--- Factory to create new btcomm
-- @table conf values from btsync.conf as parsed into Lua table
local function init(btconf)
  if not btconf.webui then error('missing webui configuration') end
  if btconf.shared_folders then error('webui disabled') end

  local ui   = btconf.webui
  local conn = {
    scheme   = 'http',
    host     = 'localhost',
    port     = 8888,
    use_auth = false,
    user     = 'User',
    pass     = 'Password',
    session  = {}
  }

  conn.host = ui.listen:match('^(%d+%.%d+%.%d+%.%d+):%d+')
  conn.port = tonumber(ui.listen:match('%d+%.%d+%.%d+%.%d+:(%d+)$'))

  if ui.login then
    conn.user = ui.login
    conn.pass = ui.password or ''
    conn.use_auth = true
  end

  return setmetatable(conn, {  __index = btcomm })
end

if _TEST then
  -- Expose private functions for busted unit testing
  btcomm.param_string = param_string
end

return init