# frozen_string_literal: true

module Boring
  module Honeybadger
    class InstallGenerator < Rails::Generators::Base
      source_root File.expand_path("templates", __dir__)
      desc 'Adds honeybadger to the app'

      class_option :use_env_variable, type: :boolean, aliases: "-ev",
                   desc: 'Use ENV variable for devise_jwt_secret_key. By default Rails credentials will be used.'

      def add_honeybadger_gem
        say 'Adding Honeybadger gem', :green

        Bundler.with_unbundled_env do
          run 'bundle add honeybadger'
        end
      end

      def configure_honeybadger_gem
        say 'Setting up Honeybadger', :green

        @api_key = honeybadger_api_key

        template 'honeybadger.yml', 'config/honeybadger.yml'

        show_readme
      end

      private

      def show_readme
        readme_template = File.read(File.join(self.class.source_root, 'README'))
        readme_content = ERB.new(readme_template).result(binding)
        say readme_content
      end

      def honeybadger_api_key
        if options[:use_env_variable]
          "ENV['HONEYBADGER_API_KEY']"
        else
          "Rails.application.credentials.dig(:honeybadger, :api_key)"
        end
      end
    end
  end
end
