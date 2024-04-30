# frozen_string_literal: true

require 'boring_generators/generator_helper'

module Boring
  module Annotate
    class InstallGenerator < Rails::Generators::Base
      include BoringGenerators::GeneratorHelper

      desc "Adds Annotate gem to the application"

      class_option :skip_on_db_migrate,
                   type: :boolean,
                   alias: "-sm",
                   default: false,
                   desc: "Skip annotate on db:migrate. Defaults to false"

      def add_annotate_gem
        if gem_installed?("annotate")
          say "annotate is already in the Gemfile, skipping it ...", :yellow
        else
          say "Adding annotate gem", :green
          gem_content = <<~RUBY
            \n
            \tgem "annotate"
          RUBY
          insert_into_file "Gemfile", gem_content, after: /group :development do/
          bundle_install
        end
      end

      def configure_annotate
        say "Configuring annotate", :green

        Bundler.with_unbundled_env do
          run "bundle exec rails g annotate:install"
        end
      end

      def update_auto_annotate_models_rake
        return unless options[:skip_on_db_migrate]

        say "Setting skip_on_db_migrate to false on file 'lib/tasks/auto_annotate_models.rake'",
            :green

        gsub_file "lib/tasks/auto_annotate_models.rake",
                  "'skip_on_db_migrate'          => 'false'",
                  "'skip_on_db_migrate'          => 'true'"
      end
    end
  end
end
