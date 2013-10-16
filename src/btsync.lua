--- lua-btsync - Interface with BitTorrent Sync's webui using Lua
-- @author Conor Heine
-- @license MIT
-- @copyright Conor Heine 2013
-- @module btsync

local http   = require 'socket.http'
local ltn12  = require 'ltn12'
local json   = require 'cjson'
local mime   = require 'mime'
local Btcomm = require 'btcomm'

--- @todo Remove step-through verbose debugger functions
local dump = require 'pl.pretty'.dump
local debug_enabled = false
local function d(data, header)
  if not debug_enabled then return end
  if header then print('--- ' .. header .. ' ---') end
  dump(data)
  if header then print('--- END ' .. header .. ' ---') end
  io.read('*l')
end

local btsync = {}

--- Private functions 
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
-- @string btconf_file Path to configuration file
local function load_btconf(btconf_file)
  local file = assert(io.open(btconf_file, 'r'))
  local text = file:read('*all')
  file:close()
  return json.decode(strip_comments(text))
end

--- Public functions
-- @section API

--- Construct new btsync object
-- @tparam string btconf_file Path to btsync.conf, default ~/.config/btsync/btsync.conf
-- @treturn table New @{btsync} object
local function init(btconf_file)
  local fpath = btconf_file or os.getenv('HOME') .. '/.config/btsync/btsync.conf'
  local conf  = load_btconf(fpath)
  local btsync_obj = {
    config = conf,
    comm   = Btcomm(conf),
    cache  = {}
  }
  return setmetatable(btsync_obj, { __index = btsync })
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

--- Get a descriptive list of active sync folders
-- @usage
-- Example response:
-- {
--   speed = "0.0 kB/s up, 0.0 kB/s down",
--   folders = {
--     {
--       secret = "ABCDEFGHIJKLMNOPQRSTUVWXYZ",
--       size = "584.7 MB in 5613 files",
--       peers = {},
--       iswritable = 1,
--       name = "/path/to/folder1",
--       readonlysecret = "ABC123ABC123ABC123ABC123"
--     },
--     {
--       secret = "ZYXWVUTSRQPONMLKJIHGFEDCBA",
--       size = "602.7 MB in 8079 files",
--       peers = {},
--       iswritable = 1,
--       name = "/path/to/folder2",
--       readonlysecret = "321CBA321CBA321CBA321CBA"
--     }
--   }
-- }
-- @treturn table Metadata for all active sync folders
function btsync:get_sync_folders()
  return json.decode(self.comm:request({ action = 'getsyncfolders' }))
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

--- Get the current user language
-- @treturn string Language code
function btsync:get_lang(b, c)
  local body = json.decode(self.comm:request({ action = 'getuserlang' }))
  return body.lang
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

--- Is the webui's language set?
-- @treturn bool true if langauge is set, false otherwise
function btsync:is_webui_language_set()
  local body = json.decode(self.comm:request({ action = 'iswebuilanguageset' }))
  return body.iswebuilanguageset == 1
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
  btsync.check_new_version = check_new_version
  btsync.get_folder_preferences = get_folder_preferences
  btsync.set_folder_preferences = set_folder_preferences
  btsync.get_hosts = get_hosts
  btsync.add_host = add_host
  btsync.remove_host = remove_host
  btsync.set_lang = set_lang
  btsync.update_secret = update_secret
  btsync.generate_invite = generate_invite
  btsync.generate_ro_invite = generate_ro_invite
  btsync.license_accept = license_accept
  btsync.license_cancel = license_cancel
  btsync.need_license = need_license
  btsync.set_webui_language = set_webui_language
  btsync.get_username = get_username
  btsync.set_credentials = set_credentials
end

return init