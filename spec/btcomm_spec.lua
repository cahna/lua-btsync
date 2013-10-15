
local load_btconf = require 'btsync'.load_btconf
local Btcomm      = require 'btcomm'

describe('btcomm', function()
  local comm, conf

  setup(function()
  	conf = load_btconf(os.getenv('HOME') .. '/.config/btsync/btsync.conf')
    comm = Btcomm(conf)
  end)

  teardown(function()
    comm = nil
  end)

  it('properly formats GET param string', function()
	local url = comm:url('token.html')
	assert.are_equal('http://0.0.0.0:8888/gui/token.html', url)
  end)
end)