# frozen_string_literal: true

module Boring
  module RailsAdmin
    class InstallGenerator < Rails::Generators::Base
      desc "Adds rails_admin to the application"
      source_root File.expand_path("templates", __dir__)

      class_option :skip_generator, type: :boolean, aliases: "-sg",
                   desc: "Skip running rails_admin install generator"
      class_option :route_name, type: :string, aliases: "-r",
                   desc: "Mount the rails_admin engine on route"

      def add_rails_admin_ruby_gem
        say "Adding rails_admin gem", :green
        Bundler.with_unbundled_env do
          run "bundle add rails_admin"
        end
      end

      def run_rails_admin_generator
        return if options[:skip_generator]
        if options[:route_name].present?
          say "Running rails_admin generator", :green
          Bundler.with_unbundled_env do
            run "DISABLE_SPRING=1 bundle exec rails generate rails_admin:install #{options[:route_name]}"
          end
        else
          say <<~WARNING, :red
            ERROR: Please specify the --route_name=<name> where you want to mount the rails_admin engine
          WARNING
        end
      end
    end
  end
end
