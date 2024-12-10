# frozen_string_literal: true

require 'boring_generators/generator_helper'

module Boring
  module Tailwind
    class InstallGenerator < Rails::Generators::Base
      include BoringGenerators::GeneratorHelper

      desc "Adds Tailwind CSS to the application"

      def add_tailwind_package
        say "Adding the gem for Tailwind CSS", :green
        
        check_and_install_gem("tailwindcss-rails")
      end

      def create_tailwind_config
        say "Initializing Tailwind CSS configurations", :green

        run "bundle exec rails tailwindcss:install"
      end
    end
  end
end
