require 'test-unit'
require 'rsync_config'

class RsyncConfigTest < Test::Unit::TestCase

  def test_load_missing_file
    assert_raise RuntimeError, 'Did not throw an error for missing file'  do
      RsyncConfig.load_file 'idontexist.conf'
    end
  end

  def test_load_file
    config = nil
    assert_nothing_raised RuntimeError do
      config = RsyncConfig.load_file 'test/etc/rsyncd.conf'
    end
    assert_equal config.class, RsyncConfig::Config, 'Did not return a config object'
  end

  def test_accessing_missing_properties_returns_nil
    config = RsyncConfig.load_file 'test/etc/rsyncd.conf'
    assert_nil config[:i_dont_exist]
  end

  def test_accessing_a_property_returns_a_string
    config = RsyncConfig.load_file 'test/etc/rsyncd.conf'
    assert_equal 'nobody', config[:uid]
  end

  def test_one_module_output
    config = RsyncConfig::Config.new
    config[:uid] = 'true'
    config[:comment] = 'false'

    ftp_module = config.module :ftp
    ftp_module[:path] = 'local'
    expected = <<EOS
uid = true
comment = false
[ftp]
    path = local
EOS
    assert_equal expected.strip, config.to_s
  end

  def test_easy_accessor_complete
    config = RsyncConfig::Config.new
    config[:uid] = 'nut'
    config[:gid] = 'kiwi'
    config[:uid] = config[:gid]
    assert_equal 'kiwi', config[:uid]
    assert_equal config[:gid], config[:uid]
  end

  def test_remove_property
    config = RsyncConfig::Config.new
    config[:uid] = 'true'
    config[:comment] = 'false'

    ftp_module = config.module :ftp
    ftp_module[:path] = 'local'

    # remove the comment config
    config[:comment] = nil
    expected = <<EOS
uid = true
[ftp]
    path = local
EOS
    assert_equal expected.strip, config.to_s
  end

  def test_module_inherits_config
    config = RsyncConfig::Config.new
    config[:uid] = 'true'
    ftp_module = config.module :ftp
    assert_equal 'true', ftp_module[:uid]
  end

end
