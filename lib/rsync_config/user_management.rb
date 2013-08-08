module RsyncConfig

  module UserManagement

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
      raise "Cannoe create secrets file #{file}" if !File.exist?(file) && ! ( Dir.exists?(File.dirname(file)) && File.writable?(File.dirname(file)))

      File.open(file, 'w') do |file|
        file.write local_user_list.join "\n"
      end

      correct_file_permissions file
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
