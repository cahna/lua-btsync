--- lua-btsync - Interface with BitTorrent Sync's webui using Lua
-- @author Conor Heine
-- @license MIT
-- @copyright Conor Heine 2013
-- @module btsync

local http   = require 'socket.http'
local ltn12  = require 'ltn12'
local json   = require 'cjson'
local mime   = require 'mime'
local band   = require 'bit'.band
local rshift = require 'bit'.rshift
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
-- @tparam[opt] boolean as_string If true, will return human-readable version number
-- @treturn[1] number Sync version
-- @treturn[2] string Human-readable version number
function btsync:get_version(as_string)
  local body = json.decode(self.comm:request({ action = 'getversion' }))

  if as_string then
    local ver = body.version
    local major = rshift(band(ver, '0xFF000000'), 24)
    local minor = rshift(band(ver, '0x00FF0000'), 16)
    local tiny  = band(ver, '0x0000FFFF')

    return major .. '.' .. minor .. '.' .. tiny
  end

  return body.version
end

--- Add a folder to be managed by btsync
-- @tparam string folder Sync folder path
-- @tparam string secret Sync folder secret
-- @treturn boolean success Returns true if sane response received
function btsync:add_sync_folder(folder, secret)
  local body = self.comm:request({ 
    action = 'addsyncfolder',
    name   = folder,
    secret = secret
  })
  return type(json.decode(body)) == 'table'
end

--- Forcibly add a folder to be managed by btsync (unsure of why this exists)
-- @tparam string folder Sync folder path
-- @tparam string secret Sync folder secret
-- @treturn boolean success Returns true if sane response received
function btsync:add_force_sync_folder(folder, secret)
  local body = self.comm:request({ 
    action = 'addsyncfolder',
    name   = folder,
    secret = secret,
    force  = 1
  })
  return type(json.decode(body)) == 'table'
end

--- Remove a folder managed by btsync
-- @tparam string folder Sync folder path
-- @tparam string secret Sync folder secret
-- @treturn boolean success Returns true if sane response received
function btsync:remove_sync_folder(folder, secret)
  local body = self.comm:request({ 
    action = 'removefolder',
    name   = folder,
    secret = secret
  })
  return type(json.decode(body)) == 'table'
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

--- Configure btsync internal settings
-- @todo Implement and test
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

--- Retrieve a folder's specific btsync preferences
-- @tparam string folder Sync folder path
-- @tparam string secret Sync folder secret
-- @treturn table Folder's preferences
function btsync:get_folder_preferences(folder, secret)
  local body = self.comm:request({ 
    action = 'getfolderpref',
    name   = folder,
    secret = secret
  })
  local data = json.decode(body)
  return data.folderpref
end

function btsync:set_folder_preferences(folder, secret)
  error('not implemented')
end

--- Get connected hosts for a folder
-- @tparam string folder Sync folder path
-- @tparam string secret Sync folder secret
-- @treturn table List of hosts
function btsync:get_hosts(folder, secret)
  local body = self.comm:request({ 
    action = 'getknownhosts',
    name   = folder,
    secret = secret
  })
  local data = json.decode(body)
  return data.hosts
end

--- Add a host to a folder managed by btsync
-- @tparam string folder Sync folder path
-- @tparam string secret Sync folder secret
-- @tparam string address Host address to be added
-- @tparam number port Host's port
-- @treturn boolean success Returns true if sane response received
function btsync:add_host(folder, secret, address, port)
  local body = self.comm:request({
    action = 'addknownhosts',
    name   = folder,
    secret = secret,
    addr   = address,
    port   = port
  })
end

--- Remove a host from a folder managed by btsync
-- @todo Implement this method
-- @todo Find out what 'index' is
-- @tparam string folder Sync folder path
-- @tparam string secret Sync folder secret
-- @tparam number index Not sure what this is...
-- @treturn boolean success Returns true if sane response received
function btsync:remove_host(folder, secret, index)
  error('not implemented')
end

--- Get the current user language
-- @treturn string Language code
function btsync:get_lang()
  local body = json.decode(self.comm:request({ action = 'getuserlang' }))
  return body.lang
end

--- Set the webui language
-- @tparam string language Language code for webui language (example: 'en' for english)
-- @treturn boolean status True if successful, false otherwise
function btsync:set_lang(language)
  local r = json.decode(self.comm:request({ 
    action = 'setuserlang',
    lang   = language
  }))
  return type(r) == 'table'
end

--- Update the secret for a folder managed by btsync
-- @tparam string folder Sync folder full path
-- @tparam string secret Sync folder secret
-- @treturn boolean True if successful, false otherwise
function btsync:update_secret(folder, secret, newsecret)
  local r = json.decode(self.comm:request({ 
    action    = 'updatesecret',
    name      = folder,
    secret    = secret,
    newsecret = newsecret
  }))
  return type(r) == 'table'
end

--- Generate a full-access invite for a sync folder
-- @tparam string folder Sync folder full path
-- @tparam string secret Sync folder secret
-- @treturn string Invite code
function btsync:generate_invite(folder, secret)
  local r = json.decode(self.comm:request({ 
    action    = 'generateinvite',
    name      = folder,
    secret    = secret
  }))
  return r.invite
end

--- Generate a readonly-access invite for a sync folder
-- @tparam string folder Sync folder full path
-- @tparam string secret Sync folder secret
-- @treturn string Readonly invite code
function btsync:generate_ro_invite(folder, secret)
  local r = json.decode(self.comm:request({ 
    action    = 'generateroinvite',
    name      = folder,
    secret    = secret
  }))
  return r.invite
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
