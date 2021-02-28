# frozen_string_literal: true

require 'bundler'

module Boring
  module Ahoy
    class InstallGenerator < Rails::Generators::Base
      desc "Adds Ahoy to the application"
      source_root File.expand_path("templates", __dir__)

      def add_twitter_omniauth_gem
        say "Adding Ahoy gem", :green
        Bundler.with_unbundled_env do
          run "bundle add ahoy_matey"
        end
      end

      def run_ahoy_generator
        say "Running Ahoy generator", :green
        Bundler.with_unbundled_env do
          run "bundle exec rails generate ahoy:install"
          run "bundle exec rails db:migrate"
        end
      end

      def show_readme
        readme "README"
      end
    end
  end
end
