---
-- lua-btsync - Interface with BitTorrent Sync's webui using Lua
-- @module btsync
-- @author Conor Heine
-- @license MIT
-- @copyright Conor Heine 2013

local http   = require 'socket.http'
local ltn12  = require 'ltn12'
local json   = require 'cjson'
local mime   = require 'mime'
local codes  = require 'httpcodes'
local Btcomm = require 'btcomm'

local btsync = {}

--- Private functions.
-- @section Private

--- Strip single-line and multi-line comments from JSON string
-- (I was unable to find a JSON decoder for Lua that gracefully
-- ignores single & multi-line comments)
local function strip_comments(txt)
  txt = txt:gsub("/%*.-%*/","")
  txt = txt:gsub("//.-\n","")
  return txt
end

--- Load the given JSON-based btsync configuration file, or default
-- to loading the conf for the current user.
-- @string conf Path to configuration file
local function load_btconf(btconf_file)
  print(btconf_file)
  local file = assert(io.open(btconf_file, 'r'))
  local text = file:read('*all')
  file:close()
  return json.decode(strip_comments(text))
end

--- Public (API) functions.
-- @section Public

--- Factory that creates new btsync interfaces
-- @string[opt='~/.config/btsync/btsync.conf'] btconf_file Path to btsync.conf
local function init(btconf_file)
  local fpath = btconf_file or os.getenv('HOME') .. '/.config/btsync/btsync.conf'
  print(fpath)
  local conf  = load_btconf(fpath)
  local btsync_obj = {
    config = conf,
    comm   = Btcomm(conf)
  }
  return setmetatable(btsync_obj, { __index = btsync })
end

--- Get a request token from BTSync webui
function btsync:request_token()
  local code, headers, body = self.comm:request({ url = 'token.html' })

  if code ~= 200 then error('HTTP '..code..': '..codes[code]) end

  return body:match('>([^<]+)<')
end

local function get_os_type(b, c)
  error('not implemented')
end

local function get_version(b, c)
  error('not implemented')
end

local function add_sync_folder(b, c)
  error('not implemented')
end

local function add_force_sync_folder(b, c)
  error('not implemented')
end

local function remove_sync_folder(b, c)
  error('not implemented')
end

local function generate_secret(b, c)
  error('not implemented')
end

local function get_settings(b, c)
  error('not implemented')
end

local function set_settings(b, c)
  error('not implemented')
end

local function get_sync_folders(b, c)
  error('not implemented')
end

local function check_new_version(b, c)
  error('not implemented')
end

local function get_folder_preferences(b, c)
  error('not implemented')
end

local function set_folder_preferences(b, c)
  error('not implemented')
end

local function get_hosts(b, c)
  error('not implemented')
end

local function add_host(b, c)
  error('not implemented')
end

local function remove_host(b, c)
  error('not implemented')
end

local function get_lang(b, c)
  error('not implemented')
end

local function set_lang(b, c)
  error('not implemented')
end

local function update_secret(b, c)
  error('not implemented')
end

local function generate_invite(b, c)
  error('not implemented')
end

local function generate_ro_invite(b, c)
  error('not implemented')
end

local function license_accept(b, c)
  error('not implemented')
end

local function license_cancel(b, c)
  error('not implemented')
end

local function need_license(b, c)
  error('not implemented')
end

local function is_webui_language_set(b, c)
  error('not implemented')
end

local function set_webui_language(b, c)
  error('not implemented')
end

local function get_username(b, c)
  error('not implemented')
end

local function set_credentials(b, c)
  error('not implemented')
end

if _TEST then
  -- Expose private functions for busted unit testing
  btsync.strip_comments = strip_comments
  btsync.load_btconf = load_btconf
  btsync.init = init
  btsync.get_os_type = get_os_type
  btsync.get_version = get_version
  btsync.add_sync_folder = add_sync_folder
  btsync.add_force_sync_folder = add_force_sync_folder
  btsync.remove_sync_folder = remove_sync_folder
  btsync.generate_secret = generate_secret
  btsync.get_settings = get_settings
  btsync.set_settings = set_settings
  btsync.get_sync_folders = get_sync_folders
  btsync.check_new_version = check_new_version
  btsync.get_folder_preferences = get_folder_preferences
  btsync.set_folder_preferences = set_folder_preferences
  btsync.get_hosts = get_hosts
  btsync.add_host = add_host
  btsync.remove_host = remove_host
  btsync.get_lang = get_lang
  btsync.set_lang = set_lang
  btsync.update_secret = update_secret
  btsync.generate_invite = generate_invite
  btsync.generate_ro_invite = generate_ro_invite
  btsync.license_accept = license_accept
  btsync.license_cancel = license_cancel
  btsync.need_license = need_license
  btsync.is_webui_language_set = is_webui_language_set
  btsync.set_webui_language = set_webui_language
  btsync.get_username = get_username
  btsync.set_credentials = set_credentials
end

return init