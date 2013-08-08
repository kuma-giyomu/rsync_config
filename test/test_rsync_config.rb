require 'test-unit'
require 'rsync_config'

class RsyncConfigTest < Test::Unit::TestCase

  TEST_INPUT_FILE = File.join(__dir__, 'etc', 'rsyncd.conf')

  TEST_OUTPUT_FILE = File.join(__dir__, 'etc', 'out', 'rsyncd.conf')

  TEST_SECRETS_FILE = File.join(__dir__, 'etc', 'out', 'secrets.conf')

  def setup
    @config = RsyncConfig::Config.new
  end

  def teardown
    @config = nil
  end

  def test_load_missing_file
    assert_raise RuntimeError, 'Did not throw an error for missing file'  do
      RsyncConfig.load_file 'idontexist.conf'
    end
  end

  def test_load_file
    assert_nothing_raised RuntimeError do
      @config = RsyncConfig.load_file TEST_INPUT_FILE
    end
    assert_equal @config.class, RsyncConfig::Config, 'Did not return a config object'
  end

  def test_accessing_missing_properties_returns_nil
    @config = RsyncConfig.load_file TEST_INPUT_FILE
    assert_nil @config[:i_dont_exist]
  end

  def test_accessing_a_property_returns_a_string
    @config = RsyncConfig.load_file TEST_INPUT_FILE
    assert_equal 'nobody', @config[:uid]
  end

  def test_one_module_output
    @config[:uid] = 'true'
    @config[:comment] = 'false'

    ftp_module = @config.module :ftp
    ftp_module[:path] = 'local'
    expected = <<EOS
uid = true
comment = false
[ftp]
    path = local
EOS
    assert_equal expected.strip, @config.to_s
  end

  def test_easy_accessor_complete
    @config[:uid] = 'nut'
    @config[:gid] = 'kiwi'
    @config[:uid] = @config[:gid]
    assert_equal 'kiwi', @config[:uid]
    assert_equal @config[:gid], @config[:uid]
  end

  def test_remove_property
    @config[:uid] = 'true'
    @config[:comment] = 'false'

    ftp_module = @config.module :ftp
    ftp_module[:path] = 'local'

    # remove the comment config
    @config[:comment] = nil
    expected = <<EOS
uid = true
[ftp]
    path = local
EOS
    assert_equal expected.strip, @config.to_s
  end

  def test_module_inherits_config
    @config[:uid] = 'true'
    ftp_module = @config.module :ftp
    assert_equal 'true', ftp_module[:uid]
  end

  def test_global_users_accessor_exists
    assert_not_nil @config.users
  end

  def test_global_users_assignment
    @config.users = {'john' => 'password'}
    assert_true @config.user?('john')
  end

  def test_global_user_existence
    @config.users = {'john' => 'password'}
    assert_true @config.user?('john')
    assert_false @config.user?('georges')
  end

  def test_module_user_existence
    ftp_module = @config.module :ftp
    ftp_module.users = {'john' => 'password'}
    assert_true ftp_module.user? 'john'
    assert_false ftp_module.user? 'george'
  end

  def test_module_user_inheritance
    @config.users = {'john' => 'password'}
    ftp_module = @config.module :ftp
    
    assert_true ftp_module.user? 'john'
    assert_false ftp_module.user? 'george'

    ftp_module.users = {'george' => 'password'}
    assert_false ftp_module.user? 'john'
    assert_true ftp_module.user? 'george'
  end

  def test_write_to_file_basic
    @config[:uid] = 'test'

    begin
      @config.write_to TEST_OUTPUT_FILE
      expected = <<EOL
uid = test
EOL
      assert_true File.exists? TEST_OUTPUT_FILE
      assert_equal expected.strip, File.read(TEST_OUTPUT_FILE).strip
    rescue ::StandardError
      fail
    ensure
      File.delete TEST_OUTPUT_FILE if File.exists? TEST_OUTPUT_FILE
    end
  end

  def test_write_to_secrets_file
    @config[:uid] = 'test'
    @config['secrets file'] = TEST_SECRETS_FILE
    @config.users['john'] = 'doe'

    begin
      @config.write_to TEST_OUTPUT_FILE
      main_expected = <<EOL
uid = test
secrets file = #{TEST_SECRETS_FILE}
EOL
      assert_true File.exists? TEST_OUTPUT_FILE
      assert_equal main_expected.strip, File.read(TEST_OUTPUT_FILE).strip

      secrets_expected = <<EOL
john:doe
EOL
      assert_true File.exists? TEST_SECRETS_FILE
      assert_equal secrets_expected.strip, File.read(TEST_SECRETS_FILE).strip
    rescue ::StandardError
      fail
    ensure
      File.delete TEST_OUTPUT_FILE if File.exists? TEST_OUTPUT_FILE
    end
  end

end
