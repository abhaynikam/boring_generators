# frozen_string_literal: true

require 'boring_generators/generator_helper'

module Boring
  module Cancancan
    class InstallGenerator < Rails::Generators::Base
      include BoringGenerators::GeneratorHelper

      desc "Adds cancancan gem to the application"

      class_option :skip_config,
                   type: :boolean,
                   default: false,
                   desc: "Skip adding cancancan configuration. Default to false"

      def add_cancancan_gem
        say "Adding cancancan gem", :green
        check_and_install_gem("cancancan")
        bundle_install
      end

      def configure_cancancan
        return if options[:skip_config]

        say "Configuring cancancan", :green

        Bundler.with_unbundled_env do
          run "bundle exec rails g cancan:ability"
        end
      end
    end
  end
end
