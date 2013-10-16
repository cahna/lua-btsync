
local Btcomm      = require 'btcomm'
local load_btconf = require 'btsync'.load_btconf

describe('btcomm module tests', function()
  local btcomm, snapshot, conf

  setup(function()
  	conf = load_btconf(os.getenv('HOME') .. '/.config/btsync/btsync.conf')
    btcomm = Btcomm(conf)
  end)

  before_each(function()
    snapshot = assert:snapshot()
  end)

  after_each(function()
    snapshot:revert()
  end)

  teardown(function()
    btcomm = nil
  end)

  it('Constructs new objects with init()/__call()', function()
  	assert.is_table(btcomm)
  	assert.is_string(btcomm.scheme)
  	assert.is_string(btcomm.host)
  	assert.is_number(btcomm.port)
  	assert.is_boolean(btcomm.use_auth)
  	assert.is_table(btcomm.session)
  	assert.is_table(btcomm.session.headers)

  	if btcomm.use_auth then
  	  assert.is_not_nil(btcomm.session.headers.Authorization)
  	end
  end)

end)