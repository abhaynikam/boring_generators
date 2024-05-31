# frozen_string_literal: true

module Boring
  module Dotenv
    class InstallGenerator < Rails::Generators::Base
      desc 'Adds dotenv gem to the application'
      source_root File.expand_path("templates", __dir__)

      def add_dotenv_gem
        say 'Adding dotenv gem', :green

        Bundler.with_unbundled_env do
          run 'bundle add dotenv-rails --group development'
        end
      end

      def configure_dotenv_gem
        say 'Configuring dotenv gem', :green

        template '.env', '.env'

        unless File.exist?('.gitignore')
          create_file '.gitignore'
        end

        FileUtils.cp('.env', '.env.sample')
        insert_into_file('.gitignore', "\n/.env\n")
      end
    end
  end
end
