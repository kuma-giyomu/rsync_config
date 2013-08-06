require 'polyglot'
require 'treetop'
require 'rsync_config/version'
require 'rsync_config/parser'
require 'rsync_config/propertiable'
require 'rsync_config/module'
require 'rsync_config/config'

module RsyncConfig
	
	def self.load_config(config_file)
		raise 'File does not exist' unless File.exists? config_file
		raise 'File is not readable' unless File.readable? config_file

		content = nil

		File.open(config_file, 'r') do |file|
			content = file.read	
		end

		parse content
	end

	def self.parse(content)
		raise 'Cannot process nil' if content.nil?

		Treetop.load 'lib/rsync_config/parser/config_file'
		parser = RsyncConfigFileParser.new
		p = parser.parse content 

		unless p.nil? 	
			return p.to_object
		else
			raise RuntimeError, parser.failure_reason
		end
	end

end
