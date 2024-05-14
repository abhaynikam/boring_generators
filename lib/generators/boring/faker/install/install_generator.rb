# frozen_string_literal: true

module Boring
  module Faker
    class InstallGenerator < Rails::Generators::Base
      desc "Adds Faker to the application"
      source_root File.expand_path("templates", __dir__)

      def add_faker_gem
        log :adding, "faker"
        Bundler.with_unbundled_env do
          run "bundle add faker --group='development,test'"
        end
      end
    end
  end
end
