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

  end

end
