module RsyncConfig

	module Propertiable
	
		def self.included base
			base.extend ClassMethods
		end

		module ClassMethods

			def allow_properties *properties
				properties.each do |property|
					property = property.to_s if property.is_a? Symbol
					property = property.downcase.strip.gsub(/_/, ' ')
					allowed_properties.push property
				end
			end

			def allowed_properties
				@allowed_properties ||= []
			end

			def allowed_property? property
				allowed_properties.include? property
			end

		end 
		
		def property(key, value = nil)
			@properties = {} unless @properties

			return nil if key.nil? 
			key = key.to_s if key.is_a? Symbol
			key = key.strip.downcase
			return nil if key.length == 0
			return nil unless self.class.allowed_property? key


			@properties[key] = value unless value.nil?

			@properties[key]
		end

		def properties_to_a
			@properties && @properties.map do |key, value|
				"#{key} = #{value}"
			end || []
		end

	end

end
