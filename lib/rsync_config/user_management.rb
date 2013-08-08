module RsyncConfig

  module UserManagement

    def users
      return @parent_config.users if @parent_config && @users.nil?
      @users ||= {}
    end

    def user? identifier
      users.include? identifier
    end

    def users= (users_list)
      @users = users_list if users_list.is_a?(Hash) || users_list.nil?
    end

  end

end
