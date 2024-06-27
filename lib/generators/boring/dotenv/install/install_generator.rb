# frozen_string_literal: true

require "boring_generators/generator_helper"

module Boring
  module Dotenv
    class InstallGenerator < Rails::Generators::Base
      include BoringGenerators::GeneratorHelper

      desc "Adds dotenv gem to the application"
      source_root File.expand_path("templates", __dir__)

      def add_dotenv_gem
        return if gem_installed?("dotenv-rails")

        say "Adding dotenv gem", :green

        check_and_install_gem "dotenv-rails", group: :development
      end

      def configure_dotenv_gem
        say "Configuring dotenv gem", :green

        template ".env", ".env"

        create_file ".gitignore" unless File.exist?(".gitignore")

        FileUtils.cp(".env", ".env.sample")

        add_env_files_to_gitignore
      end

      private

      def add_env_files_to_gitignore
        if File.readlines(".gitignore").any? { |line| line.include?(".env") }
          return
        end

        ignore_content = <<~ENV_FILE_NAMES
          \n
          # Ignore all environment files (except templates).
          /.env
          !/.env.*
        ENV_FILE_NAMES

        insert_into_file(".gitignore", ignore_content)
      end
    end
  end
end
