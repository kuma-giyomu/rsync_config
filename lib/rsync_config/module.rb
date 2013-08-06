module RsyncConfig

	class Module

		include Propertiable

		def initialize(name)
			@name = name
		end

		def to_s
			(["[#{@name}]"] + properties_to_a.map {|p| "    #{p}"}).join "\n"
		end

	end

end
