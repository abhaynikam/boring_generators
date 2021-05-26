# frozen_string_literal: true

require 'bundler'
require 'generators/boring/oauth/base_generator'

module Boring
  module Oauth
    module Github
      class InstallGenerator < Rails::Generators::Base
        include Boring::Oauth::BaseGenerator

        class MissingDeviseConfigurationError < StandardError; end

        desc "Adds GitHub OmniAuth to the application"
        source_root File.expand_path("templates", __dir__)

        def add_github_omniauth_gem
          say "Adding GitHub OmniAuth gem", :green
          Bundler.with_unbundled_env do
            run "bundle add omniauth-github"
          end
        end

        def invoke_common_generator_methods
          @oauth_name = :github
          add_provider_and_uuid_user_details
          configure_devise_omniauth
          add_omniauth_callback_routes
          add_omniauth_callback_controller
          configure_and_add_devise_setting_in_user_model
          show_readme
        end
      end
    end
  end
end
