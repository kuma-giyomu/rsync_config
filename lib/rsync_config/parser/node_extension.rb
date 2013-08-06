module RsyncConfig
	module Node

		class Config < Treetop::Runtime::SyntaxNode

			def to_object
				@config = ::RsyncConfig::Config.new

				@active_module = nil
				crawl self 

				@config
			end

			private 

			def crawl(root)
				return if root.elements.nil?

				root.elements.each do |elt|
					class_name = elt.class.name
					if class_name == 'RsyncConfig::Node::Property'
						if @active_module 
							@active_module.property elt.property.text_value, elt.value.text_value
						else
							@config.property elt.property.text_value, elt.value.text_value
						end

					elsif class_name == 'RsyncConfig::Node::Module'
						@active_module = @config.module elt.module_label.text_value

					else
						crawl elt
					end
				end
			end

		end

		class Module < Treetop::Runtime::SyntaxNode
		end

		class Property < Treetop::Runtime::SyntaxNode
		end
	end
end
