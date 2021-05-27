# frozen_string_literal: true

module Boring
  module Stimulus
    class InstallGenerator < Rails::Generators::Base
      desc "Adds Stimulus to the application"
      source_root File.expand_path("templates", __dir__)

      def add_stimulus_ruby_gem
        say "Adding Stimulus gem", :green
        Bundler.with_unbundled_env do
          run "bundle add stimulus-rails"
        end
      end

      def generating_devise_defaults
        say "Generating stimulus defaults", :green
        Bundler.with_unbundled_env do
          run "DISABLE_SPRING=1 bundle exec rails stimulus:install"
        end
      end
    end
  end
end
