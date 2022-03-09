# frozen_string_literal: true

module Boring
  module FactoryBot
    class InstallGenerator < Rails::Generators::Base
      desc "Adds FactoryBot to the application"
      source_root File.expand_path("templates", __dir__)

      class_option :skip_factory, type: :boolean, aliases: "-s",
                                  desc: "Skips adding sample factory"

      def add_factory_bot_gem
        say "Adding FactoryBot gem", :green
        Bundler.with_unbundled_env do
          run "bundle add factory_bot_rails --group='developement,test'"
        end
      end

      def add_sample_factory
        return if options[:skip_factory]

        say "Adding example factory", :green
        copy_file "users.rb", "test/factories/users.rb"
      end

      def add_factory_bot_helper_method
        say "Adding factory_bot helper method", :green
        data = <<~RUBY
          include FactoryBot::Syntax::Methods
        RUBY

        inject_into_file "test/test_helper.rb", optimize_indentation(data, 2),
                                                after: /ActiveSupport::TestCase*\n/,
                                                verbose: false
      end
    end
  end
end
