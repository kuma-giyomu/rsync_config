require 'polyglot'
require 'treetop'
require 'rsync_config/version'
require 'rsync_config/parser'
require 'rsync_config/propertiable'
require 'rsync_config/user_management'
require 'rsync_config/module'
require 'rsync_config/config'

module RsyncConfig
  
  def self.load_file(config_file)
    Config.load_file config_file
  end

  def self.parse(content)
    Config.parse content
  end

end
