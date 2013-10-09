---
-- lua-btsync tests
---

describe('lua-btsync api', function()
  local btsync

  setup(function()
    btsync = require 'btsync'
  end)

  after_each(function()
    -- Do stuff after a test
  end)

  teardown(function()
    btsync = nil
  end)

  it('request', function()
  	assert.has_error(function() btsync:request() end, 'Not implemented')
  end)

  it('requestToken', function()
  	assert.has_error(function() btsync:requestToken() end, 'Not implemented')
  end)

  it('getOsType', function()
  	assert.has_error(function() btsync:getOsType() end, 'Not implemented')
  end)

  it('getVersion', function()
  	assert.has_error(function() btsync:getVersion() end, 'Not implemented')
  end)

  it('addSyncFolder', function()
  	assert.has_error(function() btsync:addSyncFolder() end, 'Not implemented')
  end)

  it('addForceSyncFolder', function()
  	assert.has_error(function() btsync:addForceSyncFolder() end, 'Not implemented')
  end)

  it('removeSyncFolder', function()
  	assert.has_error(function() btsync:removeSyncFolder() end, 'Not implemented')
  end)

  it('generateSecret', function()
  	assert.has_error(function() btsync:generateSecret() end, 'Not implemented')
  end)

  it('getSettings', function()
  	assert.has_error(function() btsync:getSettings() end, 'Not implemented')
  end)

  it('setSettings', function()
  	assert.has_error(function() btsync:setSettings() end, 'Not implemented')
  end)

  it('getSyncFolders', function()
  	assert.has_error(function() btsync:getSyncFolders() end, 'Not implemented')
  end)

  it('checkNewVersion', function()
  	assert.has_error(function() btsync:checkNewVersion() end, 'Not implemented')
  end)

  it('getFolderPreferences', function()
  	assert.has_error(function() btsync:getFolderPreferences() end, 'Not implemented')
  end)

  it('setFolderPreferences', function()
  	assert.has_error(function() btsync:setFolderPreferences() end, 'Not implemented')
  end)

  it('getHosts', function()
  	assert.has_error(function() btsync:getHosts() end, 'Not implemented')
  end)

  it('addHost', function()
  	assert.has_error(function() btsync:addHost() end, 'Not implemented')
  end)

  it('removeHost', function()
  	assert.has_error(function() btsync:removeHost() end, 'Not implemented')
  end)

  it('getLang', function()
  	assert.has_error(function() btsync:getLang() end, 'Not implemented')
  end)

  it('setLang', function()
  	assert.has_error(function() btsync:setLang() end, 'Not implemented')
  end)

  it('updateSecret', function()
  	assert.has_error(function() btsync:updateSecret() end, 'Not implemented')
  end)

  it('generateInvite', function()
  	assert.has_error(function() btsync:generateInvite() end, 'Not implemented')
  end)

  it('generateROInvite', function()
  	assert.has_error(function() btsync:generateROInvite() end, 'Not implemented')
  end)

  it('licenseAccept', function()
  	assert.has_error(function() btsync:licenseAccept() end, 'Not implemented')
  end)

  it('licenseCancel', function()
  	assert.has_error(function() btsync:licenseCancel() end, 'Not implemented')
  end)

  it('needLicense', function()
  	assert.has_error(function() btsync:needLicense() end, 'Not implemented')
  end)

  it('iswebuiLanguageSet', function()
  	assert.has_error(function() btsync:iswebuiLanguageSet() end, 'Not implemented')
  end)

  it('setwebuiLanguage', function()
  	assert.has_error(function() btsync:setwebuiLanguage() end, 'Not implemented')
  end)

  it('getUserName', function()
  	assert.has_error(function() btsync:getUserName() end, 'Not implemented')
  end)

  it('setCredentials', function()
  	assert.has_error(function() btsync.setCredentials() end, 'Not implemented')
  end)

end)