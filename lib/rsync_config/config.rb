module RsyncConfig

	class Config

		include Propertiable

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

		def initialize
			@modules = {}
		end

		def module(key)
			raise ArgumentError if key.nil?
			key = key.to_s if key.is_a? Symbol
			key = key.strip
			raise ArgumentError if key.length == 0

			@modules[key] = Module.new(key) unless @modules[key]

			@modules[key]
		end

		def to_s
			out = properties_to_a.join "\n"

			@modules &&	@modules.each do |key, mod|
				out += "\n" + mod.to_s
			end

			out
		end

		def debug
			debugger
		end

	end

end
