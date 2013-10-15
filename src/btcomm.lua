--- Communications library for interfacing with BTSync
-- @module btcomm
-- @author Conor Heine
-- @license MIT
-- @copyright Conor Heine 2013

local http  = require 'socket.http'
local ltn12 = require 'ltn12'
local json  = require 'cjson'
local mime  = require 'mime'

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

--- Properly formats a request URL for the given path and optional GET parameters
-- based on loaded btsync config
function btcomm:url(path, params)
  return ('%s://%s:%d/gui/%s%s'):format(self.scheme, self.host, self.port, path, param_string(params))
end

--- Performs http request and return sane response data (wrapper for http.request)
function btcomm:request(r)
  if not r.url then error('Missing request URL') end

  local response = {}
  local save     = ltn12.sink.table(response)
  local headers  = {}

  if self.use_auth then
    headers.Authorization = "Basic " .. (mime.b64(self.user .. ":" .. self.pass))
  end

  local q = { 
    url     = self:url(r.url, r.params),
    sink    = save,
    headers = headers,
    method  = r.method  or 'GET'
  }

  local ok, code, headers = http.request(q)

  if not ok then error('Failed request') end

  return code, headers, response[1]
end

--- Factory to create new btcomm
-- @table conf values from btsync.conf as parsed into Lua table
local function init(btconf)
  if not btconf.webui then error('missing webui configuration') end
  if btconf.shared_folders then error('webui disabled') end

  local ui   = btconf.webui
  local conf = {
    scheme   = 'http',
    host     = 'localhost',
    port     = 8888,
    use_auth = false,
    user     = 'User',
    pass     = 'Password'
  }

  conf.host = ui.listen:match('^(%d+%.%d+%.%d+%.%d+):%d+')
  conf.port = tonumber(ui.listen:match('%d+%.%d+%.%d+%.%d+:(%d+)$'))

  if ui.login then
    conf.user = ui.login
    conf.pass = ui.password or ''
    conf.use_auth = true
  end

  return setmetatable(conf, {  __index = btcomm })
end

if _TEST then
  -- Expose private functions for busted unit testing
  btcomm.param_string = param_string
end

return init