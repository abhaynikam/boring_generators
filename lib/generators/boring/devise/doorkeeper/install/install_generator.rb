# frozen_string_literal: true

module Boring
  module Devise
    module Doorkeeper
      class InstallGenerator < Rails::Generators::Base
        desc "Adds doorkeeper with devise to the application"

        class_option :model_name, type: :string, aliases: "-m", default: "User",
                     desc: "Tell us the user model name which will be used for authentication. Defaults to User"
        class_option :grant_flows, type: :array, aliases: "-gf", default: %w[authorization_code client_credentials],
                     enum: %w[authorization_code client_credentials password],
                     desc: "Tell us the grant flows you want to use separated by space. Defaults to authorization_code and client_credentials"
        class_option :api_only, type: :boolean, aliases: "-a", default: false,
                     desc: "Tell us if you want to setup doorkeeper for API only application. Defaults to false"
        class_option :skip_applications_routes, type: :boolean, aliases: "-sr", default: false,
                     desc: "Tell us if you want to skip adding doorkeeper routes to manage applications. Defaults to false"
        class_option :use_refresh_token, type: :boolean, aliases: "-rt", default: false,
                     desc: "Keep user logged in with refresh tokens. Defaults to false"

        def verify_presence_of_devise_gem
          gem_file_content_array = File.readlines("Gemfile")
          devise_is_installed = gem_file_content_array.any? { |line| line.include?('devise') }

          return if devise_is_installed

          say "We couldn't find devise gem. Please configure devise gem and rerun the generator. Consider running `rails generate boring:devise:install` to set up Devise.",
              :red

          abort
        end

        def verify_presence_of_devise_model
          return if File.exist?("app/models/#{options[:model_name].underscore}.rb")

          say "We couldn't find the #{options[:model_name]} model. Maybe there is a typo? Please provide the correct model name and run the generator again.",
              :red

          abort
        end

        def add_doorkeeper_gem
          say "Adding doorkeeper gem", :green
          Bundler.with_unbundled_env do
            run "bundle add doorkeeper"
          end
        end

        def run_doorkeeper_generators
          say "Running doorkeeper generators", :green

          Bundler.with_unbundled_env do
            run "bundle exec rails generate doorkeeper:install"
            run "bundle exec rails generate doorkeeper:migration"
          end
        end

        def add_doorkeeper_related_association_to_model
          model_name = options[:model_name].underscore
          say "Adding doorkeeper related associations to the model file app/models/#{model_name}.rb",
              :green
          model_content = <<~RUBY
            has_many :access_grants,
                     class_name: 'Doorkeeper::AccessGrant',
                     foreign_key: :resource_owner_id,
                     dependent: :delete_all # or :destroy if you need callbacks

            has_many :access_tokens,
                     class_name: 'Doorkeeper::AccessToken',
                     foreign_key: :resource_owner_id,
                     dependent: :delete_all # or :destroy if you need callbacks
          RUBY

          inject_into_file "app/models/#{model_name}.rb",
                           optimize_indentation(model_content, 2),
                           after: "ApplicationRecord\n"
        end

        def update_doorkeeper_initializer
          say "Updating doorkeeper initializer", :green

          configure_resource_owner_authenticator if options[:grant_flows].include?("authorization_code")
          configure_admin_authenticator unless options[:api_only] || options[:skip_applications_routes]
          configure_resource_owner_from_credentials if options[:grant_flows].include?("password")

          gsub_file "config/initializers/doorkeeper.rb",
                    /# grant_flows %w\[authorization_code client_credentials\]/,
                    "grant_flows %w[#{options[:grant_flows].uniq.join(' ')}]"

          if options[:api_only]
            gsub_file "config/initializers/doorkeeper.rb",
                      /# api_only/,
                      "api_only"
          end

          if options[:skip_applications_routes]
            doorkeeper_routes_content = <<~RUBY
              use_doorkeeper do
                skip_controllers :applications, :authorized_applications
              end
            RUBY
            
            gsub_file "config/routes.rb",
                      /.*use_doorkeeper/,
                      optimize_indentation(doorkeeper_routes_content, 2)
          end

          if options[:use_refresh_token]
            uncomment_lines "config/initializers/doorkeeper.rb",
                            /use_refresh_token/
          end
        end

        def update_doorkeeper_migration
          say "Updating doorkeeper migration", :green
          model_name = options[:model_name].underscore

          uncomment_lines Dir["db/migrate/*_create_doorkeeper_tables.rb"].first,
                          /add_foreign_key :oauth/

          gsub_file Dir["db/migrate/*_create_doorkeeper_tables.rb"].first,
                    /<model>/,
                    ":#{model_name.pluralize}"

          return unless (%w[password client_credentials] & options[:grant_flows]).any?

          gsub_file Dir["db/migrate/*_create_doorkeeper_tables.rb"].first,
                    /t.text    :redirect_uri, null: false/,
                    "t.text    :redirect_uri"
        end

        def show_message
          return if options[:api_only] || options[:skip_applications_routes]

          model_name = options[:model_name].underscore
          admin_authenticator_content = "current_#{model_name} || warden.authenticate!(scope: :#{model_name})"

          say "\nWe've implemented `#{admin_authenticator_content}` in the admin_authenticator block of config/initializers/doorkeeper.rb to manage access to application routes. Please adjust it as necessary to suit your requirements.",
              :yellow
        end

        private

        def configure_resource_owner_authenticator
          model_name = options[:model_name].underscore
          resource_owner_authenticator_content = <<~RUBY
            resource_owner_authenticator do
              current_#{model_name} || warden.authenticate!(scope: :#{model_name})
            end
          RUBY

          gsub_file "config/initializers/doorkeeper.rb",
                    /.*resource_owner_authenticator do\n(?:\s|.)*?end/,
                    optimize_indentation(resource_owner_authenticator_content, 2)
        end

        def configure_admin_authenticator
          model_name = options[:model_name].underscore
          gsub_file "config/initializers/doorkeeper.rb",
                    /(?:# admin_authenticator do\n*)((?:\s|.)*?)(?:# end)/,
                    "admin_authenticator do\n" + "\\1" + "end"

          admin_authenticator_content = "current_#{model_name} || warden.authenticate!(scope: :#{model_name})"
          inject_into_file "config/initializers/doorkeeper.rb",
                           optimize_indentation(admin_authenticator_content, 4),
                           after: /admin_authenticator do\n/,
                           force: true

        end

        def configure_resource_owner_from_credentials
          model_name = options[:model_name].underscore
          resource_owner_for_credentials_content = <<~RUBY
            resource_owner_from_credentials do |routes|
              #{model_name} = #{options[:model_name]}.find_for_database_authentication(email: params[:email])
              if #{model_name}&.valid_for_authentication? { #{model_name}.valid_password?(params[:password]) } && #{model_name}&.active_for_authentication?
                request.env['warden'].set_user(#{model_name}, scope: :#{model_name}, store: false)
                #{model_name}
              end
            end
          RUBY

          inject_into_file "config/initializers/doorkeeper.rb",
                           optimize_indentation(resource_owner_for_credentials_content, 2),
                           after: /resource_owner_authenticator do\n(?:\s|.)*?end\n/
        end
      end
    end
  end
end
