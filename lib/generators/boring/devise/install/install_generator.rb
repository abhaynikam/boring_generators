# frozen_string_literal: true

module Boring
  module Devise
    class InstallGenerator < Rails::Generators::Base
      desc "Adds devise to the application"

      DEFAULT_DEVISE_MODEL_NAME = "User"

      class_option :model_name, type: :string, aliases: "-m",
                   desc: "Tell us the user model name which will be used for authentication. Defaults to #{DEFAULT_DEVISE_MODEL_NAME}"
      class_option :skip_devise_view, type: :boolean, aliases: "-sv",
                   desc: "Skip generating devise views"
      class_option :skip_devise_model, type: :boolean, aliases: "-sm",
                   desc: "Skip generating devise model"
      class_option :add_turbo, type: :boolean, aliases: "-at",
                   desc: "Add turbo to navigational formats"

      def add_devise_gem
        say "Adding devise gem", :green
        Bundler.with_unbundled_env do
          run "bundle add devise"
        end
      end

      def generating_devise_defaults
        say "Generating devise defaults", :green
        Bundler.with_unbundled_env do
          run "DISABLE_SPRING=1 bundle exec rails generate devise:install"
        end
      end

      def add_devise_action_mailer_development_config
        say "Adding devise Action Mailer development configuration", :green
        insert_into_file "config/environments/development.rb", <<~RUBY, after: /Rails.application.configure do/
          \n
          \tconfig.action_mailer.default_url_options = { host: 'localhost', port: 3000 }
        RUBY
      end

      def add_devise_user_model
        return if options[:skip_devise_model]

        say "Adding devise user model", :green
        model_name = options[:model_name] || DEFAULT_DEVISE_MODEL_NAME

        Bundler.with_unbundled_env do
          run "DISABLE_SPRING=1 bundle exec rails generate devise #{model_name}"
        end
      end

      def add_devise_authentication_filter_to_application_controller
        insert_into_file "app/controllers/application_controller.rb", <<~RUBY, after: /class ApplicationController < ActionController::Base/
          \n
          \tbefore_action :authenticate_user!
        RUBY
      end

      def add_devise_views
        return if options[:skip_devise_view]

        say "Adding devise views", :green
        model_name = options[:model_name] || DEFAULT_DEVISE_MODEL_NAME

        Bundler.with_unbundled_env do
          run "DISABLE_SPRING=1 bundle exec rails generate devise:views #{model_name.pluralize}"
        end
      end
      def add_turbo_stream
        if options[:add_turbo]
          insert_into_file "config/initializers/devise.rb", <<~RUBY, after: /config.mailer_sender = 'please-change-me-at-config-initializers-devise@example.com'/
            \n
            \tconfig.navigational_formats = ['*/*', :html, :turbo_stream]
        RUBY
        end
      end
    end
  end
end
