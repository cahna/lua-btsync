---
-- lua-btsync tests
---
local Btsync = require 'btsync'

describe('lua-btsync api tests for a running Sync instance', function()
  local btsync, snapshot

  setup(function()
    btsync = Btsync()
  end)

  before_each(function()
    snapshot = assert:snapshot()
  end)

  after_each(function()
    snapshot:revert()
  end)

  teardown(function()
    btsync = nil
  end)

  it('creates new btsync objects properly', function() 
    assert.is_table(btsync)
    assert.is_table(btsync.config)
    assert.is_table(btsync.comm)
  end)

  pending('load_btconf')

  pending('init')

  it('get_os_type', function()
    assert.are_equal(btsync:get_os_type(), 'linux')
  end)

  it('get_version', function()
    assert.is_number(btsync:get_version())

    local str_version = btsync:get_version(true)
    assert.is_string(str_version)
    assert.is_string(str_version:match('(%d+.%d+.%d+)'))
  end)

  pending('add_sync_folder')

  pending('add_force_sync_folder')

  pending('remove_sync_folder')

  it('generate_secret', function()
    local s = btsync:generate_secret()
    assert.is_table(s)
    assert.is_string(s.secret)
    assert.is_string(s.rosecret)
  end)

  it('get_settings', function()
    local settings = btsync:get_settings()
    assert.is_table(settings)
    assert.is_string(settings.devicename)
    assert.is_number(settings.listeningport)
    assert.is_number(settings.dlrate)
    assert.is_number(settings.ulrate)
    assert.is_number(settings.portmapping)
  end)

  pending('set_settings')

  it('get_sync_folders', function() 
    local folder_data  = btsync:get_sync_folders()

    assert.is_table(folder_data)
    assert.is_string(folder_data.speed)
    assert.is_table(folder_data.folders)

    for _,folder in ipairs(folder_data.folders) do
      assert.is_string(folder.secret)
      assert.is_string(folder.size)
      assert.is_table(folder.peers)
      assert.is_number(folder.iswritable)
      assert.is_string(folder.name)
      assert.is_string(folder.readonlysecret)
    end
  end)

  pending('check_new_version')

  it('get_folder_preferences', function()
    local folder_data = btsync:get_sync_folders()

    for _,folder in ipairs(folder_data.folders) do
      local prefs = btsync:get_folder_preferences(folder.name, folder.secret)
      assert.is_table(prefs)
      assert.is_number(prefs.deletetotrash)
      assert.is_number(prefs.iswritable)
      assert.is_string(prefs.readonlysecret)
      assert.is_number(prefs.searchdht)
      assert.is_number(prefs.searchlan)
      assert.is_number(prefs.usehosts)
      assert.is_number(prefs.usetracker)
    end
  end)

  pending('set_folder_preferences')

  it('get_hosts', function()
    local folder_data = btsync:get_sync_folders()

    for _,folder in ipairs(folder_data.folders) do
      local prefs = btsync:get_hosts(folder.name, folder.secret)
      assert.is_table(prefs)
    end
  end)

  pending('add_host')

  pending('remove_host')

  it('get_lang', function() 
    assert.are_equal(btsync:get_lang(), 'en')
  end)

  it('set_lang', function()
    assert.is_true(btsync:set_lang('en'))
  end)

  pending('update_secret')

  it('generate_invite', function()
    local folder_data = btsync:get_sync_folders()

    for _,folder in ipairs(folder_data.folders) do
      local invite = btsync:generate_invite(folder.name, folder.secret)
      assert.is_string(invite)
    end
  end)

  it('generate_ro_invite', function()
    local folder_data = btsync:get_sync_folders()

    for _,folder in ipairs(folder_data.folders) do
      local invite = btsync:generate_ro_invite(folder.name, folder.secret)
      assert.is_string(invite)
    end
  end)

  it('license_accept', function()
    assert.is_true(btsync:license_accept())
  end)

  it('license_cancel', function()
    assert.is_true(btsync:license_cancel())
  end)

  it('need_license', function()
    assert.is_boolean(btsync:need_license())
  end)

  it('is_webui_language_set', function() 
    assert.is_true(btsync:is_webui_language_set())
  end)

  pending('set_webui_language')

  pending('get_username')

  pending('set_credentials')


end)