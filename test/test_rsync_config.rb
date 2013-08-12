require 'test-unit'
require 'rsync_config'

class RsyncConfigTest < Test::Unit::TestCase

  TEST_INPUT_FILE = File.join(__dir__, 'etc', 'rsyncd.conf')

  TEST_INPUT_FILE_WITH_SECRETS = File.join(__dir__, 'etc', 'rsyncd_with_secrets.conf')

  TEST_OUTPUT_FILE = File.join(__dir__, 'etc', 'out', 'rsyncd.conf')

  TEST_SECRETS_FILE = File.join(__dir__, 'etc', 'out', 'secrets.conf')

  def teardown
    File.delete TEST_OUTPUT_FILE if File.exists? TEST_OUTPUT_FILE
    File.delete TEST_SECRETS_FILE if File.exists? TEST_SECRETS_FILE
  end

  def make_new_config
    RsyncConfig::Config.new
  end

  def make_simple_config
    RsyncConfig.load_file TEST_INPUT_FILE
  end

  def make_secrets_config
    RsyncConfig.load_file TEST_INPUT_FILE_WITH_SECRETS
  end

  def test_load_missing_file
    assert_raise RuntimeError, 'Did not throw an error for missing file'  do
      RsyncConfig.load_file 'idontexist.conf'
    end
  end

  def test_load_file_does_not_crash
    config = nil
    assert_nothing_raised RuntimeError do
      config = make_simple_config
    end

    assert_equal config.class, RsyncConfig::Config, 'Did not return a config object' end

  def test_accessing_missing_properties_returns_nil
    config = make_new_config

    assert_nil config[:i_dont_exist]
  end

  def test_accessing_a_property_returns_a_string
    config = make_new_config
    config[:uid] = 'nobody'

    assert_equal 'nobody', config[:uid]
  end

  def test_one_module_output
    config = make_new_config
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

    assert_equal expected.strip, config.to_config_file
  end

  def test_module_listing
    config = make_new_config
    config.module :ftp
    config.module :smb
    config.module :something

    assert_equal ['ftp', 'smb', 'something'], config.module_names
  end

  def test_easy_accessor_complete
    config = make_new_config
    config[:uid] = 'nut'
    config[:gid] = 'kiwi'
    config[:uid] = config[:gid]

    assert_equal 'kiwi', config[:uid]
    assert_equal config[:gid], config[:uid]
  end

  def test_remove_property
    config = make_new_config
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
    config = make_new_config
    config[:uid] = 'true'
    ftp_module = config.module :ftp

    assert_equal 'true', ftp_module[:uid]
  end

  def test_global_users_accessor_exists
    config = make_new_config

    assert_not_nil config.users
  end

  def test_global_users_assignment
    config = make_new_config
    config.users = {'john' => 'password'}

    assert_true config.user?('john')
  end

  def test_global_user_existence
    config = make_new_config
    config.users = {'john' => 'password'}

    assert_true config.user?('john')
    assert_false config.user?('georges')
  end

  def test_module_user_existence
    config = make_new_config
    ftp_module = config.module :ftp
    ftp_module.users = {'john' => 'password'}

    assert_true ftp_module.user? 'john'
    assert_false ftp_module.user? 'george'
  end

  def test_module_user_inheritance
    config = make_new_config
    config.users = {'john' => 'password'}
    ftp_module = config.module :ftp
    
    assert_true ftp_module.user? 'john'
    assert_false ftp_module.user? 'george'

    ftp_module.users = {'george' => 'password'}
    assert_false ftp_module.user? 'john'
    assert_true ftp_module.user? 'george'
  end

  def test_write_to_file_succeeds
    config = make_new_config

    config.write_to TEST_OUTPUT_FILE
    assert_true File.exists? TEST_OUTPUT_FILE
  end

  def test_write_to_file_has_correct_content
    config = make_new_config
    config[:uid] = 'test'

    config.write_to TEST_OUTPUT_FILE
    expected = <<EOL
uid = test
EOL
    assert_equal expected.strip, File.read(TEST_OUTPUT_FILE).strip
  end

  def test_write_to_secrets_file_succeeds
    config = make_simple_config
    config['secrets file'] = TEST_SECRETS_FILE
    config.users['john'] = 'doe'

    config.write_to TEST_OUTPUT_FILE

    assert_true File.exists? TEST_SECRETS_FILE
  end

  def test_write_to_secrets_file_has_correct_permissions
    config = make_new_config
    config['secrets file'] = TEST_SECRETS_FILE
    config.users['john'] = 'doe'

    config.write_to TEST_OUTPUT_FILE

    assert_nil File.world_readable? TEST_SECRETS_FILE
    assert_nil File.world_writable? TEST_SECRETS_FILE
  end

  def test_write_correct_content_to_secrets_file
    config = make_new_config
    config['secrets file'] = TEST_SECRETS_FILE
    config.users['john'] = 'doe'

    config.write_to TEST_OUTPUT_FILE

    secrets_expected = <<EOL
john:doe
EOL
    assert_equal secrets_expected.strip, File.read(TEST_SECRETS_FILE).strip
  end

  def test_module_secrets_user_exists
    config = make_secrets_config
    assert_true config.module(:ftp).user? 'john'
  end

  def test_global_secrets_user_exists
    config = make_secrets_config
    assert_true config.user? 'bob'
  end

  def test_module_overriden_secrets_does_not_include_global_users
    config = make_secrets_config
    assert_false config.module(:ftp).user? 'bob'
  end
end
