# frozen_string_literal: true

require 'bundler'

module Boring
  module Oauth
    module Facebook
      class InstallGenerator < Rails::Generators::Base
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

        def add_provider_and_uuid_user_details
          say "Adding migration to add provider and uuid columns to users", :green
          Bundler.with_unbundled_env do
            run "DISABLE_SPRING=1 bundle exec rails generate migration AddOmniauthToUsers provider:string uid:string"
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

        def add_omniauth_callback_routes
          devise_route = '# devise_for :users, controllers: { omniauth_callbacks: "users/omniauth_callbacks" }'.dup
          route devise_route
        end

        def add_omniauth_callback_controller
          say "Copying omniauth_callbacks_controller.rb", :green
          template("omniauth_callbacks_controller.rb", "app/controllers/users/omniauth_callbacks_controller.rb")
        end

        def configure_and_add_devise_setting_in_user_model
          say "Configuring facebook omniauth for user model", :green
          insert_into_file "app/models/user.rb", <<~RUBY, after: /class User < ApplicationRecord/

              \tdevise :omniauthable, omniauth_providers: %i[facebook]

              \tdef self.from_omniauth(auth)
                \twhere(provider: auth.provider, uid: auth.uid).first_or_create do |user|
                  \tuser.email = auth.info.email
                  \tuser.password = Devise.friendly_token[0, 20]
                  \tuser.name = auth.info.name   # assuming the user model has a name
                  \t# user.image = auth.info.image # assuming the user model has an image
                  \t# If you are using confirmable and the provider(s) you use validate emails,
                  \t# uncomment the line below to skip the confirmation emails.
                  \t# user.skip_confirmation!
                \tend
              \tend
          RUBY
        end

        def add_the_facebook_devise_omniauth_view
          insert_into_file "app/views/users/sessions/new.html.erb", <<~RUBY, after: /<%= render "users\/shared\/links" %>/

            <%= link_to "Sign in with Facebook", user_facebook_omniauth_authorize_path %>
          RUBY
        end

        def show_readme
          readme "README"
        end
      end
    end
  end
end
