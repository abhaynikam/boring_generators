# frozen_string_literal: true

module Boring
  module Rspec
    class InstallGenerator < Rails::Generators::Base
      desc "Adds RSpec to the application"
      source_root File.expand_path("templates", __dir__)

      class_option :skip_factory_bot, type: :boolean, aliases: "-sfb",
                                      desc: "Skips installing factory bot"
      class_option :skip_faker, type: :boolean, aliases: "-sf",
                                desc: "Skips faker install"

      def add_rspec_gem
        log :adding, "rspec-rails"
        Bundler.with_unbundled_env do
          run "bundle add rspec-rails --group='developement,test'"
        end
      end

      def run_rspec_active_record_generator
        log :running, "rspec generator"
        Bundler.with_unbundled_env do
          run "rails generate rspec:install"
        end
      end

      def add_rspec_initializer
        log :override, "test_framework to rspec"
        environment <<~end_of_config
          config.generators do |g|
            g.test_framework :rspec
          end
        end_of_config
      end

      def add_factory_bot
        return if options[:skip_factory_bot]

        Rails::Command.invoke :generate, ["boring:factory_bot:install"]
      end

      def add_faker_gem
        return if options[:skip_faker]

        Rails::Command.invoke :generate, ["boring:faker:install"]
      end
    end
  end
end
