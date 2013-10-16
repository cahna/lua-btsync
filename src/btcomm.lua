--- Communications library for interfacing with BTSync webui and persisting
-- session state/data.
-- @author Conor Heine
-- @license MIT
-- @copyright Conor Heine 2013
-- @module btcomm

local http  = require 'socket.http'
local url   = require 'socket.url'
local ltn12 = require 'ltn12'
local json  = require 'cjson'
local mime  = require 'mime'
local codes = require 'httpcodes'

--- @todo Remove step-through verbose debugger functions
local dump  = require 'pl.pretty'.dump
local debug_enabled = false

local function d(data, header)
  if not debug_enabled then return end
  if header then print('--- ' .. header .. ' ---') end
  dump(data)
  if header then print('--- END ' .. header .. ' ---') end
  io.read('*l')
end

local btcomm = {}

--- Private functions
-- @section Private

--- Takes a table of key-value pairs and formats it to GET request param string
-- @tparam table p key-value pairs describing GET params as: `param = value` 
-- @return 
local function build_query(p)
  if p == nil then return '' end

  local pstr = ''
  for param, val in pairs(p) do
    pstr = pstr .. url.escape(param) .. '=' .. url.escape(val) .. '&'
  end

  return pstr:gsub('&$', '')
end

--- Takes set-cookie string and parses it into a table
-- @tparam string set_cookie set-cookie string from response headers
local function explode_cookie(set_cookie)
  local c = {}
  
  set_cookie = set_cookie .. ' ' -- make gmatch play nice

  for cookie_name, cookie_val in set_cookie:gmatch("(.-)=(.-);? ") do
    c[cookie_name] = cookie_val
  end

  return c
end

--- Format table of `cookie = value` key-value pairs and formats them
-- into a cookie string for a request header
-- @tparam table string Header string in the form `cookie_name = value`
local function implode_cookie(cookies)
  local c = ''
  
  for name, val in pairs(cookies) do
    c = c .. name .. '=' .. val .. '; '
  end

  return c:gsub('; $', '')
end

--- Perform HTTP request based on request_data table
-- @tparam table request_data 
-- @treturn bool status Request success status
-- @treturn int code HTTP status code
-- @treturn headers table Response headers
-- @treturn string body Response body
local function do_request(request_data)
  local response  = {}
  local save      = ltn12.sink.table(response)
  local query_tab = request_data.query   or {}
  local url_parts = {
    scheme = request_data.scheme,
    path   = request_data.path,
    query  = build_query(request_data.query),
    port   = request_data.port or 8080,
    host   = request_data.host
  }

  d(url.build(url_parts), 'BUILD URL')

  local r = {
    sink     = save,
    url      = url.build(url_parts),
    headers  = request_data.headers or {},
    method   = request_data.method  or 'GET',
    redirect = false
  }

  d(r, 'DO_REQUEST r{}')

  local ok, code, headers = http.request(r)

  d(headers, 'RESPONSE HEADERS')

  if not ok then error('Failed request') end

  d(response[1], 'RESPONSE BODY')

  return ok, code, headers, response[1]
end

--- Public functions 
-- @section API

--- Update client session cookie with response header's 'set-cookie' values
-- @tparam string set_cookie 'set-cookie' value from server response header
function btcomm:update_session_cookie(set_cookie)
  if not self.session.headers.cookie then
    self.session.headers.cookie = {}
  end

  response_cookie = explode_cookie(set_cookie)

  -- Merge response cookies into session
  for name,value in pairs(response_cookie) do
    self.session.headers.cookie[name] = value
  end

  d(self.session.headers.cookie, 'SESSION COOKIE')
end

--- Get a request token from BTSync webui
-- @treturn string Token
function btcomm:request_token()
  local request_data = {
    scheme  = self.scheme,
    path    = '/gui/token.html',
    query   = { t = os.time() },
    port    = self.port,
    host    = self.host,
    headers = {
      Authorization = self.use_auth and self.session.headers.Authorization or nil
    },
    method  = 'POST'
  }

  d(request_data, 'REQUEST DATA')

  local ok, code, headers, body = do_request(request_data)

  if headers['set-cookie'] then
    self:update_session_cookie(headers['set-cookie'])
  end

  return body:match('>([^<]+)<') -- This is how BitTorrent's webui.js does this
end

--- Performs http request and return sane response data
-- @tparam table query_tab GET request query variables. 
-- `{ key = val }` => `'?key=val'`. `{ key = true }` => `'?key'`.
-- @tparam[opt] string method Override request method, default 'GET'
-- @tparam[opt] string path Optional relative path
-- @treturn string Response Body
function btcomm:request(query_tab, method, path)
  if not self.session.token then
    self.session.token = self:request_token()
  end

  -- Insert signing token & timestamp
  query_tab.token = self.session.token
  query_tab.t     = os.time()

  -- Build request
  local request_data = {
    scheme  = self.scheme,
    path    = '/gui/' .. (path or ''),
    query   = query_tab,
    port    = self.port,
    host    = self.host,
    headers = { Connection = 'keep-alive' },
    method  = mothod or 'GET'
  }

  if self.use_auth then
    request_data.headers.Authorization = self.session.headers.Authorization
  end

  if self.session.headers.cookie then
    request_data.headers.Cookie = implode_cookie(self.session.headers.cookie)
  end

  d(request_data, 'REQUEST DATA')

  local ok, code, headers, body = do_request(request_data)

  -- Set/update cookie values (if needed)
  if headers['set-cookie'] then
    self:update_session_cookie(headers['set-cookie'])
  end

  if code ~= 200 then 
    error('HTTP '..code..': '..codes[code]) 
  end

  return body
end

--- Construct new btcomm object
-- @usage 
-- local Btcomm = require 'btcomm'
-- local config = {
--   webui = {
--     listen   = '0.0.0.0:8888',
--     login    = 'Username', -- Optional
--     password = 'Password'  -- Optional
--   }
-- }
-- local my_btcomm_obj = Btcomm(config)
-- @name btcomm
-- @tparam table conf Values from btsync.conf (uses localhost:8888 without auth if omitted)
-- @return table New @{btcomm} object
local function init(self, btconf)
  if not btconf.webui then error('missing webui configuration') end
  if btconf.shared_folders then error('webui disabled') end

  local ui   = btconf.webui

  --- Instance variables in new @{btcomm} object
  local instance = {
    scheme   = 'http',          -- string: Request scheme, default 'http'
    host     = 'localhost',     -- string: Sync webui host, default 'localhost'
    port     = 8888,            -- int: Sync webui port, default 8888
    use_auth = false,           -- bool: Use authentication? default, false
    session  = {                -- table: Holds session/cache data
      headers = {}              -- table: Used to persist headers across requests
    }
  }

  instance.host = ui.listen:match('^(%d+%.%d+%.%d+%.%d+):%d+')
  instance.port = tonumber(ui.listen:match('%d+%.%d+%.%d+%.%d+:(%d+)$'))

  if ui.login then
    instance.use_auth = true
    instance.session.headers.Authorization = 'Basic ' .. (mime.b64(ui.login .. ":" .. ui.password))
  end

  return setmetatable(instance, {  __index = btcomm })
end

-- Expose private functions for busted unit testing
if _TEST then
  btcomm.implode_cookie = implode_cookie
  btcomm.explode_cookie = explode_cookie
  btcomm.do_request     = do_request
end

return setmetatable(btcomm, { __call = init })
