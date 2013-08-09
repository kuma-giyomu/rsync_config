module RsyncConfig

  module Node

    module Crawlable

      def crawl *args
        continue = true
        continue = action(*args) if respond_to? :action

        return if !continue || elements.nil?

        elements.each do |elt|
          elt.crawl(*args)
        end
      end

    end

    class Treetop::Runtime::SyntaxNode

      include ::RsyncConfig::Node::Crawlable

    end

  end

end
