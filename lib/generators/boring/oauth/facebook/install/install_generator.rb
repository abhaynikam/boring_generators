# frozen_string_literal: true

require 'bundler'
require 'generators/boring/oauth/base_generator'

module Boring
  module Oauth
    module Facebook
      class InstallGenerator < Rails::Generators::Base
        include Boring::Oauth::BaseGenerator

        class MissingDeviseConfigurationError < StandardError; end

        desc "Adds facebook OmniAuth to the application"
        source_root File.expand_path("templates", __dir__)

        def add_facebook_omniauth_gem
          say "Adding Facebook OmniAuth gem", :green
          facebook_omniauth_gem = <<~RUBY
            \n
            # for omniauth facebook
            gem 'omniauth-facebook', '~> 8.0'
          RUBY
          append_to_file "Gemfile", facebook_omniauth_gem
          Bundler.with_unbundled_env do
            run "bundle install"
          end
        end

        def configure_devise_omniauth_facebook
          say "Adding omniauth devise configuration", :green
          if File.exist?("config/initializers/devise.rb")
            insert_into_file "config/initializers/devise.rb", <<~RUBY, after: /Devise.setup do \|config\|/
              \n
              \tconfig.omniauth :facebook, "APP_ID", "APP_SECRET"
            RUBY
          else
            raise MissingDeviseConfigurationError, <<~ERROR
              Looks like the devise installation is incomplete. Could not find devise.rb in config/initializers.
            ERROR
          end
        end

        def invoke_common_generator_methods
          add_provider_and_uuid_user_details
          add_omniauth_callback_routes
          configure_and_add_devise_setting_in_user_model
          show_readme
        end
      end
    end
  end
end
