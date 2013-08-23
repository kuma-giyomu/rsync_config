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
    
    def [](key, local_only = false)
      key = sanitize_key(key)
      return nil if key.nil? 

      value = properties[key]
      return @parent_config[key] if !local_only && value.nil? && @parent_config.respond_to?(:[])

      value
    end

    def sanitize_key(key)
      key = key.to_s unless key.is_a? String
      key = key.strip.downcase
      return nil if key.length == 0
      return nil unless self.class.allowed_property? key
      key
    end

    def []=(key, value)
      key = sanitize_key(key)
      if value.nil?
        properties.delete key
      elsif value.is_a? ConfigEntry
        properties[key] = value
      else
        properties[key] = value.to_s
      end
    end

    def properties_to_a
      properties.map { |key, value| "#{key} = #{value.to_s}" }
    end

    private 
    
    def properties
      @properties ||= {}
    end
    
  end

end
