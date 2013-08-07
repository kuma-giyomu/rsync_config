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

	def test_accessing_missing_properties_returns_nil
		config = RsyncConfig.load_config 'test/etc/rsyncd.conf'
		assert_nil config.property(:i_dont_exist)
	end

	def test_accessing_a_property_returns_a_string
		config = RsyncConfig.load_config 'test/etc/rsyncd.conf'
		assert_equal 'nobody', config.property(:uid)
	end

	def test_one_module_output
		config = RsyncConfig::Config.new
		config.property :uid, 'true'
		config.property :comment, 'false'

		config.module(:ftp).property :path, 'local'
		expected = <<EOS
uid = true
comment = false
[ftp]
    path = local
EOS
		assert_equal expected.strip, config.to_s
	end

end
