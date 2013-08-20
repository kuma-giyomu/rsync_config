module RsyncConfig

  module UserManagement

    def self.included base
      base.extend ClassMethods
    end

    module ClassMethods

      def parse_secrets_file(content)
        raise 'Cannot process nil' if content.nil?

        Treetop.load File.join(__dir__, 'parser/secrets_file')
        parser = RsyncSecretsFileParser.new
        p = parser.parse content

        unless p.nil?
          return p.to_hash
        else
          raise RuntimeError, parser.failure_reason
        end
      end

    end

    def users
      return @parent_config.users if @parent_config && @users.nil?
      local_users
    end

    def local_users
      @users ||= {}
    end

    def user? identifier
      users.include? identifier
    end

    def users= (users_list)
      @users = users_list if users_list.is_a?(Hash) || users_list.nil?
    end

    def local_user_list
      # we need to output only what is related to this specific node
      local_users.keys.map do |user|
        "#{user}:#{local_users[user]}"
      end 
    end

    def write_secrets_file(file)
      return if file.nil?
      raise "Cannot write secrets file #{file}" if File.exists?(file) && ! File.writable?(file)
      raise "Cannot create secrets file #{file}" if !File.exist?(file) && ! ( Dir.exists?(File.dirname(file)) && File.writable?(File.dirname(file)))

      File.open(file, 'w') do |file|
        file.write local_user_list.join "\n"
      end

      correct_file_permissions file
    end

    def load_secrets_file(file)
      # fails silently if no parameter is found OR the file does not exist on disk
      return if file.nil? || !(File.exist? file)

      # fails is the file exists but cannot be read, since it's suspicious
      raise "Cannot load secrets file #{file}" unless File.readable?(file)

      File.open(file, 'r') do |file|
        self.users = self.class.parse_secrets_file(file.read)
      end
    end

    private 

    def correct_file_permissions(file)
      if File.world_readable?(file) || File.world_writable?(file)
        # reuse existing permissions but remove everything from world
        File.chmod (File.stat(file).mode & 0770), file
      end
    end

  end

end
