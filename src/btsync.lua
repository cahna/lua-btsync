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
-- @usage 
-- local Btsync = require 'btsync'
-- local btsync_obj = Btsync('~/.config/btsync/btsync.conf')
-- @tparam string btconf_file Path to btsync.conf, default `~/.config/btsync/btsync.conf`
-- @treturn table New @{btsync} object
local function init(self, btconf_file)
  local fpath = btconf_file or os.getenv('HOME') .. '/.config/btsync/btsync.conf'
  local conf  = load_btconf(fpath)
  local btsync_obj = {
    config = conf,
    comm   = Btcomm(conf)
  }
  return setmetatable(btsync_obj, { __index = btsync })
end

--- Get the OS type for the Sync instance
-- @treturn string OS type (linux, windows, etc...)
function btsync:get_os_type()
  local body = json.decode(self.comm:request({ action = 'getostype' }))
  return body.os
end

--- Get the version number for the Sync instance
-- @treturn number Sync version
function btsync:get_version(b, c)
  local body = json.decode(self.comm:request({ action = 'getversion' }))
  return body.version
end

function btsync:add_sync_folder(b, c)
  self.comm:request({ 
    action = 'addsyncfolder',
    name   = folder,
    secret = secret
  })
end

function btsync:add_force_sync_folder(b, c)
  self.comm:request({ 
    action = 'addsyncfolder',
    name   = folder,
    secret = secret,
    force  = 1
  })
end

function btsync:remove_sync_folder(folder, secret)
  self.comm:request({ 
    action = 'removefolder',
    name   = folder,
    secret = secret
  })
end

--- Request a new secret and read-only secret
-- @treturn table Newly generated secret & read-only secret
-- @field secret Secret
-- @field rosecret Read-only secret
function btsync:generate_secret()
  return json.decode(self.comm:request({ action = 'generatesecret' }))
end

--- Get BT Sync settings
-- @return @{bt_settings}
function btsync:get_settings()
  local body = json.decode(self.comm:request({ action = 'getsettings' }))
  return body.settings
end

function btsync:set_settings(b, c)
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

--- Check for new version of BT Sync software
-- @treturn @{bt_check_new_version}
function btsync:check_new_version()
  return self.comm:request({ action = 'checknewversion' })
end

function btsync:get_folder_preferences(folder, secret)
  error('not implemented')
end

function btsync:set_folder_preferences(folder, secret)
  error('not implemented')
end

function btsync:get_hosts(folder, secret)
  error('not implemented')
end

function btsync:add_host(folder, secret, address, port)
  error('not implemented')
end

function btsync:remove_host(folder, secret, index)
  error('not implemented')
end

--- Get the current user language
-- @treturn string Language code
function btsync:get_lang()
  local body = json.decode(self.comm:request({ action = 'getuserlang' }))
  return body.lang
end

function btsync:set_lang(language)
  error('not implemented')
end

function btsync:update_secret(folder, secret, newsecret)
  error('not implemented')
end

function btsync:generate_invite(folder, secret)
  error('not implemented')
end

function btsync:generate_ro_invite(folder, secret)
  error('not implemented')
end

--- Accept the BT Sync software terms
-- @treturn boolean status True if successful, false otherwise
function btsync:license_accept()
  local r = json.decode(self.comm:request({ action = 'accept' }))
  return type(r) == 'table'
end

--- Revoke acceptance of the BT Sync software terms
-- @treturn boolean status True if successful, false otherwise
function btsync:license_cancel()
  local r = json.decode(self.comm:request({ action = 'cancel' }))
  return type(r) == 'table'
end

--- Determine whether the license terms need to be accepted
-- @treturn boolean status True if the terms have NOT been agreed to yet, false otherwise
function btsync:need_license()
  local body = json.decode(self.comm:request({ action = 'license' }))
  return body.agreed == 0
end

--- Is the webui's language set?
-- @treturn bool true if langauge is set, false otherwise
function btsync:is_webui_language_set()
  local body = json.decode(self.comm:request({ action = 'iswebuilanguageset' }))
  return body.iswebuilanguageset == 1
end

--- Set the webui language?
-- @todo Verify behavior of this action
-- @treturn boolean status True if successful, false otherwise
function btsync:set_webui_language()
  local r = json.decode(self.comm:request({ action = 'setwebuilanguage' }))
  return type(r) == 'table'
end

--- Get the username for Sync
-- @treturn string username
function btsync:get_username()
  local body = json.decode(self.comm:request({ action = 'getusername' }))
  return body.username
end

--- Change password for Sync webui
function btsync:set_credentials(user, old_pass, new_pass)
  self.comm:request({
    action = 'setcred',
    username = user,
    newpwd = new_pass,
    oldpwd = old_pass
  })
end

--- Detailed return values
-- @section returns

--- Table returned by @{btsync:get_settings}
-- @tfield string devicename Sync computer name
-- @tfield number listeningport Sync webui listed port
-- @tfield number dlrate Download rate
-- @tfield number ulrate Upload rate
-- @tfield number portmapping 1 if portmapping is enabled, 0 otherwise
-- @table bt_settings

--- Table returned by @{btsync:check_new_version}
-- @tfield string url Url of new version of Sync
-- @tfield number version New version number for Sync
-- @table bt_check_new_version

if _TEST then
  btsync.load_btconf = load_btconf
end

return setmetatable(btsync, { __call = init })