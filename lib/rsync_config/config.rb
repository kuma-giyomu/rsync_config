module RsyncConfig

	class Config

		include Propertiable

		def initialize
			@modules = {}
		end

		def module(key)
			raise ArgumentError if key.nil?
			key = key.strip.to_sym if key.is_a? String
			raise ArgumentError if key.length == 0

			@modules[key] = Module.new(key) unless @modules[key]

			@modules[key]
		end

		def to_s
			out = properties_to_a.join "\n"

			@modules.each do |key, mod|
				out += "\n" + mod.to_s
			end

			out
		end

	end

end
