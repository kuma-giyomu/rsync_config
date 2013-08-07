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

		def method_missing(method_name, *args)
			
			property_name = method_name.to_s.gsub(/_/, ' ').gsub(/=$/, '')

			if self.class.allowed_property? property_name

				self.class.class_eval do
					# define getter
					
					define_method property_name do 
						property property_name
					end

					# define setter
					define_method "#{property_name}=" do |arg|
						property property_name, arg
					end
				end

				# call the method
				send method_name, *args
			else
				super
			end

		end

		def respond_to_missing?(method_name)
			property_name = sanitize_method_name(method_name).gsub(/=$/, '')
			self.class.allowed_property? property_name || super
		end

		private

		def sanitize_property(property)
			property = property.to_s unless property.is_a? String
			property.strip.downcase
		end

		def sanitize_method_name(method)
			sanitize_property(method).gsub(/[\s]+/, '_')
		end

	end

end
