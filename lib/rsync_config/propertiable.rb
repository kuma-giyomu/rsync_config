module RsyncConfig

	module Propertiable
		
		def property(key, value = nil)
			return nil if key.nil? 
			key = key.strip.to_sym if key.is_a? String
			return nil if key.length == 0

			@properties = {} if @properties.nil?

			@properties[key] = value unless value.nil?

			@properties[key]
		end

		def properties_to_a
			@properties.map do |key, value|
				"#{key} = #{value}"
			end
		end

	end

end
