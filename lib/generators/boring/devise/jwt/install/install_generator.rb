# frozen_string_literal: true

require 'boring_generators/generator_helper'

module Boring
  module Devise
    module Jwt
      class InstallGenerator < Rails::Generators::Base
        include Rails::Generators::Migration
        include BoringGenerators::GeneratorHelper

        desc "Add devise-jwt to the application"
        source_root File.expand_path('templates', __dir__)

        class_option :model_name, type: :string, aliases: "-m",
                     default: "User",
                     desc: "Tell us the user model name which will be used for authentication. Defaults to User"
        class_option :use_env_variable, type: :boolean, aliases: "-ev",
                     desc: "Use ENV variable for devise_jwt_secret_key. By default Rails credentials will be used."
        class_option :revocation_strategy, type: :string, aliases: "-rs",
                     enum: %w[JTIMatcher Denylist Allowlist],
                     default: "Denylist",
                     desc: "Tell us the revocation strategy to be used. Defaults to Denylist"
        class_option :expiration_time_in_days, type: :numeric, aliases: "-et",
                      default: 15,
                      desc: "Tell us the expiration time on days for the JWT token. Defaults to 15 days"

        def self.next_migration_number(dirname)
          next_migration_number = current_migration_number(dirname) + 1
          ActiveRecord::Migration.next_migration_number(next_migration_number)
        end

        def verify_presence_of_devise_gem
          return if gem_installed?("devise")

          say "We couldn't find devise gem. Please configure devise gem and rerun the generator. Consider running `rails generate boring:devise:install` to set up Devise.",
              :red

          abort
        end

        def verify_presence_of_devise_initializer
          return if File.exist?("config/initializers/devise.rb")

          say "We couldn't find devise initializer. Please configure devise gem and rerun the generator. Consider running `rails generate boring:devise:install` to set up Devise.",
              :red

          abort
        end

        def verify_presence_of_devise_model
          return if File.exist?("app/models/#{options[:model_name].underscore}.rb")

          say "We couldn't find the #{options[:model_name]} model. Maybe there is a typo? Please provide the correct model name and run the generator again.", :red

          abort
        end

        def add_devise_jwt_gem
          say "Adding devise-jwt gem", :green
          check_and_install_gem("devise-jwt")
          bundle_install
        end

        def add_devise_jwt_config_to_devise_initializer
          say "Adding devise-jwt configurations to a file `config/initializers/devise.rb`", :green

          jwt_config = <<~RUBY
            config.jwt do |jwt|
              jwt.secret = #{devise_jwt_secret_key}
              jwt.dispatch_requests = [
                ['POST', %r{^/sign_in$}]
              ]
              jwt.revocation_requests = [
                ['DELETE', %r{^/sign_out$}]
              ]
              jwt.expiration_time = #{options[:expiration_time_in_days]}.day.to_i
            end
          RUBY

          inject_into_file "config/initializers/devise.rb",
                            optimize_indentation(jwt_config, 2),
                            before: /^end\s*\Z/m

          say "❗️❗️\nValue for jwt.secret will be used from `#{devise_jwt_secret_key}`. You can change this values if they don't match with your app.\n",
              :yellow
        end

        def configure_revocation_strategies
          say "Configuring #{options[:revocation_strategy]} revocation strategy",
              :green

          case options[:revocation_strategy]
          when "JTIMatcher"
            configure_jti_matcher_strategy
          when "Denylist"
            configure_denylist_strategy
          when "Allowlist"
            configure_allowlist_strategy
          end
        end

        private

        def devise_jwt_secret_key
          if options[:use_env_variable]
            "ENV['DEVISE_JWT_SECRET_KEY']"
          else
            "Rails.application.credentials.devise_jwt_secret_key"
          end
        end

        def configure_jti_matcher_strategy
          @model_db_table = options[:model_name].tableize
          @model_class = @model_db_table.camelcase

          migration_template "add_jti_to_users.rb", "db/migrate/add_jti_to_#{@model_db_table}.rb"

          add_devise_jwt_module(
            strategy: "self",
            include_content: "include Devise::JWT::RevocationStrategies::JTIMatcher"
          )
        end

        def configure_denylist_strategy
          Bundler.with_unbundled_env do
            run "bundle exec rails generate model jwt_denylist --skip-migration"
          end

          migration_template "create_jwt_denylist.rb", "db/migrate/create_jwt_denylist.rb"

          add_devise_jwt_module(strategy: "JwtDenylist")
          
          jwt_denylist_content = <<~RUBY
            include Devise::JWT::RevocationStrategies::Denylist
            self.table_name = 'jwt_denylist'
          RUBY

          inject_into_file "app/models/jwt_denylist.rb",
                           optimize_indentation(jwt_denylist_content, 2),
                           after: /ApplicationRecord\n/,
                           verbose: false
        end

        def configure_allowlist_strategy
          @model_underscore = options[:model_name].underscore
          Bundler.with_unbundled_env do
            run "bundle exec rails generate model allowlisted_jwt --skip-migration"
          end

          migration_template "create_allowlisted_jwts.rb", "db/migrate/create_allowlisted_jwts.rb"

          add_devise_jwt_module(
            strategy: "self",
            include_content: "include Devise::JWT::RevocationStrategies::Allowlist"
          )
        end

        def add_devise_jwt_module(strategy:, include_content: nil)
          model_name = options[:model_name].underscore
          model_content = File.read("app/models/#{model_name}.rb")
          devise_module_pattern = /devise\s*(?:(?:(?::\w+)|(?:\w+:\s*\w+))(?:(?:,\s*:\w+)|(?:,\s*\w+:\s*\w+))*)/

          if model_content.match?(devise_module_pattern)
            inject_into_file "app/models/#{model_name}.rb",
                              ", :jwt_authenticatable, jwt_revocation_strategy: #{strategy}",
                              after: devise_module_pattern
          else
            inject_into_file "app/models/#{model_name}.rb",
                             optimize_indentation(
                               "devise :jwt_authenticatable, jwt_revocation_strategy: #{strategy}",
                               2
                             ),
                             after: /ApplicationRecord\n/
            say "Successfully added the devise-jwt module to #{model_name} model. However, it looks like the devise module is missing from the #{model_name} model. Please configure the devise module to ensure everything functions correctly.",
                :yellow
          end

          if include_content
            inject_into_file "app/models/#{model_name}.rb",
                             optimize_indentation(include_content, 2),
                             after: /ApplicationRecord\n/,
                             verbose: false
          end
        end
      end
    end
  end
end
