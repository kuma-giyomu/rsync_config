module RsyncConfig

  class Module

    include Propertiable
    include UserManagement

    # module properties
    allow_properties :comment, :path, :use_chroot, :numeric_ids, :munge_symlinks, :charset
    allow_properties :max_connections, :log_file, :syslog_facility, :max_verbosity, :lock_file
    allow_properties :read_only, :write_only, :list, :uid, :gid, :fake_super, :filter, :exclude, :include
    allow_properties :exclude_from, :include_from, :incoming_chmod, :outgoing_chmod, :auth_users
    allow_properties :secrets_file, :strict_modes, :hosts_allow, :hosts_deny, :reverse_lookup
    allow_properties :forward_lookup, :ignore_errors, :ignore_nonreadable, :transfer_logging
    allow_properties :log_format, :timeout, :refuse_options, :dont_compress, 'pre-xfer exec', 'post-xfer exec'

    def initialize(parent_config, name)
      @parent_config = parent_config
      @name = name
    end

    def to_s
      (["[#{@name}]"] + properties_to_a.map {|p| "    #{p}"}).join "\n"
    end

  end

end
