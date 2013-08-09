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

    # --------------------- CONFIG FILE NODES --------------------

    class Config < Treetop::Runtime::SyntaxNode

      attr_accessor :config, :active_module

      def to_config
        @config = ::RsyncConfig::Config.new
        @active_module = nil

        crawl self 

        @config
      end

    end

    class Module < Treetop::Runtime::SyntaxNode

      def action(top_node)
        top_node.active_module = top_node.config.module(module_label.text_value)

        # interrupt subtree crawling
        false
      end

    end

    class Property < Treetop::Runtime::SyntaxNode

      def action(top_node)
        receiver = top_node.active_module.nil? ? top_node.config : top_node.active_module
        receiver[property.text_value] = value.text_value

        # interrupt subtree crawling
        false
      end

    end

    # ------------ SECRETS FILE NODES ----------------

    class Secrets < Treetop::Runtime::SyntaxNode

      def to_hash
        {}
      end

    end

    class UserRecord < Treetop::Runtime::SyntaxNode

      def user_value
        user.text_value
      end

      def password_value
        password.text_value
      end

    end

  end

end
