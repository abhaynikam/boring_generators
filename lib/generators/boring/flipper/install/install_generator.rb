# frozen_string_literal: true

module Boring
  module Flipper
    class InstallGenerator < Rails::Generators::Base
      desc "Adds Active Record Flipper to the application"
      source_root File.expand_path("templates", __dir__)

      def add_flipper_gem
        say "Adding Flipper gem", :green
        Bundler.with_unbundled_env do
          run "bundle add flipper-active_record flipper-ui"
        end
      end

      def run_flipper_active_record_generator
        say "Running Active Record Flipper generator", :green
        Bundler.with_unbundled_env do
          run "bundle exec rails generate flipper:active_record"
          run "bundle exec rails db:migrate"
        end
      end

      def add_flipper_initializer
        say "Adding Flipper initializer", :green
        copy_file "initializer.rb", "config/initializers/flipper.rb"
      end

      def add_flipper_routes
        say "Adding Flipper UI routes", :green
        route <<~ROUTE
          mount Flipper::UI.app(Flipper) => '/admins/flipper'
        ROUTE
      end
    end
  end
end
