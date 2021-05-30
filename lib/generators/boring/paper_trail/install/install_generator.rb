# frozen_string_literal: true

module Boring
  module PaperTrail
    class InstallGenerator < Rails::Generators::Base
      desc "Adds paper trail to the application"
      source_root File.expand_path("templates", __dir__)

      class_option :skip_generator, type: :boolean, aliases: "-sg",
                   desc: "Skip running paper_trail install generator"
      class_option :skip_user_track_config, type: :boolean, aliases: "-sutc",
                   desc: "Skip adding config for tracking devise user in paper_trail"

      def add_bullet_gem
        say "Adding paper trail gems", :green
        Bundler.with_unbundled_env do
          run "bundle add paper_trail"
        end
      end

      def run_paper_trail_generator
        return if options[:skip_generator]

        say "Running rails_admin generator", :green
        Bundler.with_unbundled_env do
          run "DISABLE_SPRING=1 bundle exec rails generate paper_trail:install --with-changes"
        end
      end

      def set_configuration_to_track_whodunnit
        return if options[:skip_user_track_config]

        say "Setting configuration to track devise current_user", :green
        insert_into_file "app/controllers/application_controller.rb", <<~RUBY, after: /class ApplicationController < ActionController::Base/
          \tbefore_action :set_paper_trail_whodunnit
        RUBY
      end
    end
  end
end
