module RsyncConfig

  class Config

    include Propertiable
    include UserManagement

    # global properties
    allow_properties :motd_file, :pid_file, :port, :address, :socket_options, :listen_backlog

    # module properties
    allow_properties :comment, :path, :use_chroot, :numeric_ids, :munge_symlinks, :charset
    allow_properties :max_connections, :log_file, :syslog_facility, :max_verbosity, :lock_file
    allow_properties :read_only, :write_only, :list, :uid, :gid, :fake_super, :filter, :exclude, :include
    allow_properties :exclude_from, :include_from, :incoming_chmod, :outgoing_chmod, :auth_users
    allow_properties :secrets_file, :strict_modes, :hosts_allow, :hosts_deny, :reverse_lookup
    allow_properties :forward_lookup, :ignore_errors, :ignore_nonreadable, :transfer_logging
    allow_properties :log_format, :timeout, :refuse_options, :dont_compress, 'pre-xfer exec', 'post-xfer exec'

    def self.load_file(config_file)
      raise 'File does not exist' unless File.exists? config_file
      raise 'File is not readable' unless File.readable? config_file

      content = nil

      File.open(config_file, 'r') do |file|
        content = file.read 
      end

      Config.parse content
    end
  
    def self.parse(content)
      raise 'Cannot process nil' if content.nil?

      Treetop.load File.join(__dir__, 'parser/config_file')
      parser = RsyncConfigFileParser.new
      p = parser.parse content 

      unless p.nil?   
        return p.to_config.after_parse
      else
        raise RuntimeError, parser.failure_reason
      end
    end

    def module(key)
      raise ArgumentError if key.nil?
      key = key.to_s if key.is_a? Symbol
      key = key.strip
      raise ArgumentError if key.length == 0

      modules[key] ||= Module.new(self, key)

      modules[key]
    end

    def to_s
      to_config_file
    end

    def to_config_file
      out = []
      properties_to_s = properties_to_a.join("\n")
      out << properties_to_s if properties_to_s.length > 0

      modules.each do |key, mod|
        out << mod.to_config_file
      end

      out.join "\n"
    end

    def write_to(file_path)
      File.open(file_path, 'w') do |file|
        file.write to_config_file
      end

      write_secrets_files
    end

    def module_names
      modules.keys
    end

    def after_parse
      batch_process_secrets_files :load_secrets_file
    end

    private

    def modules
      @modules ||= {}
    end

    def write_secrets_files
      batch_process_secrets_files :write_secrets_file
    end

    def batch_process_secrets_files(method_name)
      send method_name, self.[]('secrets file', true)

      modules.each_value do |rmodule|
        rmodule.send method_name, rmodule.[]('secrets file', true)
      end

      self
    end

  end

end
