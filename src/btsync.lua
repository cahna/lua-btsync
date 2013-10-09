---
-- lua-btsync
---

local btsync = {}

local function request(a, e, d, b)
	error('Not implemented')
end

local function requestToken(c, b)
	error('Not implemented')
end

local function getOsType(b, c)
	error('Not implemented')
end

local function getVersion(b, c)
	error('Not implemented')
end

local function addSyncFolder(b, c)
	error('Not implemented')
end

local function addForceSyncFolder(b, c)
	error('Not implemented')
end

local function removeSyncFolder(b, c)
	error('Not implemented')
end

local function generateSecret(b, c)
	error('Not implemented')
end

local function getSettings(b, c)
	error('Not implemented')
end

local function setSettings(b, c)
	error('Not implemented')
end

local function getSyncFolders(b, c)
	error('Not implemented')
end

local function checkNewVersion(b, c)
	error('Not implemented')
end

local function getFolderPreferences(b, c)
	error('Not implemented')
end

local function setFolderPreferences(b, c)
	error('Not implemented')
end

local function getHosts(b, c)
	error('Not implemented')
end

local function addHost(b, c)
	error('Not implemented')
end

local function removeHost(b, c)
	error('Not implemented')
end

local function getLang(b, c)
	error('Not implemented')
end

local function setLang(b, c)
	error('Not implemented')
end

local function updateSecret(b, c)
	error('Not implemented')
end

local function generateInvite(b, c)
	error('Not implemented')
end

local function generateROInvite(b, c)
	error('Not implemented')
end

local function licenseAccept(b, c)
	error('Not implemented')
end

local function licenseCancel(b, c)
	error('Not implemented')
end

local function needLicense(b, c)
	error('Not implemented')
end

local function iswebuiLanguageSet(b, c)
	error('Not implemented')
end

local function setwebuiLanguage(b, c)
	error('Not implemented')
end

local function getUserName(b, c)
	error('Not implemented')
end

local function setCredentials(b, c)
	error('Not implemented')
end

if _TEST then
  -- Expose private functions for busted unit testing
  btsync.request              = request
  btsync.requestToken         = requestToken
  btsync.getOsType            = getOsType
  btsync.getVersion           = getVersion
  btsync.addSyncFolder        = addSyncFolder
  btsync.addForceSyncFolder   = addForceSyncFolder
  btsync.removeSyncFolder     = removeSyncFolder
  btsync.generateSecret       = generateSecret
  btsync.getSettings          = getSettings
  btsync.setSettings          = setSettings
  btsync.getSyncFolders       = getSyncFolders
  btsync.checkNewVersion      = checkNewVersion
  btsync.getFolderPreferences = getFolderPreferences
  btsync.setFolderPreferences = setFolderPreferences
  btsync.getHosts             = getHosts
  btsync.addHost              = addHost
  btsync.removeHost           = removeHost
  btsync.getLang              = getLang
  btsync.setLang              = setLang
  btsync.updateSecret         = updateSecret
  btsync.generateInvite       = generateInvite
  btsync.generateROInvite     = generateROInvite
  btsync.licenseAccept        = licenseAccept
  btsync.licenseCancel        = licenseCancel
  btsync.needLicense          = needLicense
  btsync.iswebuiLanguageSet   = iswebuiLanguageSet
  btsync.setwebuiLanguage     = setwebuiLanguage
  btsync.getUserName          = getUserName
  btsync.setCredentials       = setCredentials
end

return setmetatable(btsync, {})