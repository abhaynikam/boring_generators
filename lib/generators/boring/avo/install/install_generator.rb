# frozen_string_literal: true

module Boring
  module Avo
    class InstallGenerator < Rails::Generators::Base
      desc 'Adds Avo to the application'

      def add_avo_gem
        say 'Adding Avo gem', :green

        Bundler.with_unbundled_env do
          run 'bundle add avo'
        end
      end

      def configure_avo
        say 'Setting up Avo', :green

        Bundler.with_unbundled_env do
          run 'bundle exec rails generate avo:install'
        end
      end
    end
  end
end
