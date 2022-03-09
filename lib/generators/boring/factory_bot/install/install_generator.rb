# frozen_string_literal: true

module Boring
  module FactoryBot
    class InstallGenerator < Rails::Generators::Base
      desc "Adds FactoryBot to the application"
      source_root File.expand_path("templates", __dir__)

      class_option :skip_factory, type: :boolean, aliases: "-s",
                                  desc: "Skips adding sample factory"
      class_option :skip_faker, type: :boolean, aliases: "-s",
                                desc: "Skips faker install"

      def add_factory_bot_gem
        log :adding, "FactoryBot"
        Bundler.with_unbundled_env do
          run "bundle add factory_bot_rails --group='developement,test'"
        end
      end

      def add_sample_factory
        return if options[:skip_factory]

        log :adding, "Sample users factory"
        copy_file "users.rb", "test/factories/users.rb"
      end

      def add_factory_bot_helper_method
        log :adding, "factory_bot helper"
        data = <<~RUBY
          include FactoryBot::Syntax::Methods
        RUBY

        inject_into_file "test/test_helper.rb", optimize_indentation(data, 2),
                                                after: /ActiveSupport::TestCase*\n/,
                                                verbose: false
      end

      def add_faker_gem
        return if options[:skip_faker]

        Rails::Command.invoke :generate, ["boring:faker:install"]
      end
    end
  end
end
