# frozen_string_literal: true

require 'boring_generators/generator_helper'

module Boring
  module Sidekiq
    class InstallGenerator < Rails::Generators::Base
      include BoringGenerators::GeneratorHelper

      desc "Adds Sidekiq to the application"
      source_root File.expand_path("templates", __dir__)

      class_option :skip_routes,
                   type: :boolean,
                   aliases: "-sr",
                   default: false,
                   desc: "Tell us if you want to skip sidekiq routes for viewing Web UI. Defaults to false."
      class_option :authenticate_routes_with_devise,
                   type: :boolean,
                   aliases: "-ar",
                   default: false,
                   desc: "Tell us if you want sidekiq routes to only be accessed by authenticated users. Defaults to false."
      class_option :skip_procfile_config,
                   type: :boolean,
                   aliases: "-sp",
                   default: false,
                   desc: "Tell us if you want to skip adding sidekiq worker to Procfile. Defaults to false."

      def add_sidekiq_gem
        say "Adding sidekiq gem to Gemfile", :green
        check_and_install_gem("sidekiq")
        bundle_install
      end

      def set_sidekiq_as_active_job_adapter
        say "Setting sidekiq as active_job adapter", :green

        inject_into_file "config/application.rb",
                         optimize_indentation(
                           "config.active_job.queue_adapter = :sidekiq\n",
                           4
                         ),
                         after: /class Application < Rails::Application\n/
                        
      end

      def add_sidekiq_routes
        return if options[:skip_routes]

        say "Adding sidekiq routes", :green

        if options[:authenticate_routes_with_devise]
          route = <<~RUBY
            authenticate :user do
              mount Sidekiq::Web => '/sidekiq'
            end

          RUBY
        else
          route = "mount Sidekiq::Web => '/sidekiq'\n\n"
        end

        inject_into_file "config/routes.rb",
                         "require 'sidekiq/web'\n\n",
                         before: "Rails.application.routes.draw do\n"

        inject_into_file "config/routes.rb",
                         optimize_indentation(route, 2),
                         after: "Rails.application.routes.draw do\n"
      end

      def add_sidekiq_worker_to_procfile
        return if options[:skip_procfile_config] || !File.exist?("Procfile.dev")

        say "Adding sidekiq worker to Procfile.dev", :green
        append_to_file "Procfile.dev", "worker: bundle exec sidekiq"
      end

      def show_message
        return if options[:skip_routes]

        if options[:authenticate_routes_with_devise]
          readme "README"
        else
          say "\nWe've added Sidekiq routes. Please protect it as necessary to suit your requirements.",
              :yellow
        end
      end
    end
  end
end
