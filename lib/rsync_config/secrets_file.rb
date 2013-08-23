module RsyncConfig
  class SecretsFile

    include ConfigEntry

    attr_accessor :value, :output

    def initialize(output, **options)
      raise "output cannot be nil or empty" if output.nil? || output.empty?

      self.output = output
      self.value = options[:value] if options[:value]
    end

    def value
      @value.nil? ? output : @value
    end

    def to_s
      value
    end
  end
end
