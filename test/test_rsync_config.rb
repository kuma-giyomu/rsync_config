require 'test-unit'
require 'rsync_config'

class RsyncConfigTest < Test::Unit::TestCase

	def test_load_missing_file
		assert_raise RuntimeError, 'Did not throw an error for missing file'  do
			RsyncConfig.load_config 'idontexist.conf'
		end
	end

	def test_load_file
		config = nil
		assert_nothing_raised RuntimeError do
			config = RsyncConfig.load_config 'test/etc/rsyncd.conf'
		end
		assert_equal config.class, RsyncConfig::Config, 'Did not return a config object'
	end

	def test_one_module_output
		config = RsyncConfig::Config.new
		config.property :g1, 'true'
		config.property :g2, 'false'

		config.module(:ftp).property :l1, 'local'
		expected = <<EOS
g1 = true
g2 = false
[ftp]
    l1 = local
EOS
		assert_equal expected.strip, config.to_s
	end

end
