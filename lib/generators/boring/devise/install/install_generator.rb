# frozen_string_literal: true

module Boring
  module Devise
    class InstallGenerator < Rails::Generators::Base
      desc "Adds devise to the application"

      DEFAULT_DEVISE_MODEL_NAME = "User"

      class_option :model_name,
                   type: :string,
                   aliases: "-m",
                   desc:
                     "Tell us the user model name which will be used for authentication. Defaults to #{DEFAULT_DEVISE_MODEL_NAME}"
      class_option :skip_devise_view,
                   type: :boolean,
                   aliases: "-sv",
                   desc: "Skip generating devise views"
      class_option :skip_devise_model,
                   type: :boolean,
                   aliases: "-sm",
                   desc: "Skip generating devise model"
      class_option :run_db_migrate,
                   type: :boolean,
                   aliases: "-rdm",
                   desc: "Run migrations after generating user table",
                   default: false

      def add_devise_gem
        say "Adding devise gem", :green
        Bundler.with_unbundled_env { run "bundle add devise" }
      end

      def generating_devise_defaults
        say "Generating devise defaults", :green
        Bundler.with_unbundled_env do
          run "DISABLE_SPRING=1 bundle exec rails generate devise:install"
        end
      end

      def add_devise_action_mailer_development_config
        say "Adding devise Action Mailer development configuration", :green
        insert_into_file "config/environments/development.rb",
                         <<~RUBY,
          \n
          \tconfig.action_mailer.default_url_options = { host: 'localhost', port: 3000 }
        RUBY
                         after: /Rails.application.configure do/
      end

      def add_devise_user_model
        return if options[:skip_devise_model]

        say "Adding devise user model", :green
        model_name = options[:model_name] || DEFAULT_DEVISE_MODEL_NAME

        Bundler.with_unbundled_env do
          run "DISABLE_SPRING=1 bundle exec rails generate devise #{model_name}"
        end

        # make the email unique
        if File.exist?("test/fixtures/users.yml")
          email_content = <<~FIXTURE
            one:
              email: example-$LABEL@email.com
          FIXTURE

          gsub_file "test/fixtures/users.yml",
                    /one: {}/,
                    optimize_indentation(email_content, 0)
        end
      end

      def add_devise_authentication_filter_to_application_controller
        insert_into_file "app/controllers/application_controller.rb",
                         <<~RUBY,
          \n
          \tbefore_action :authenticate_user!
        RUBY
                         after:
                           /class ApplicationController < ActionController::Base/
      end

      def add_devise_views
        return if options[:skip_devise_view]

        say "Adding devise views", :green
        model_name = options[:model_name] || DEFAULT_DEVISE_MODEL_NAME

        Bundler.with_unbundled_env do
          run "DISABLE_SPRING=1 bundle exec rails generate devise:views #{model_name.pluralize}"
        end
      end

      def run_db_migrate
        return unless options[:run_db_migrate]

        Bundler.with_unbundled_env { rails_command "db:migrate" }
      end
    end
  end
end
