module RsyncConfig
	module Node

		class Config < Treetop::Runtime::SyntaxNode

			def to_object
				config = ::RsyncConfig::Config.new
				config.property :test, '1'

				config
			end

		end

		class Module < Treetop::Runtime::SyntaxNode
		end

		class Property < Treetop::Runtime::SyntaxNode
		end
	end
end
