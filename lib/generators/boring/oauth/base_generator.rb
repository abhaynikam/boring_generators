# frozen_string_literal: true

require 'bundler'

module Boring
  module Oauth
    module BaseGenerator
      def add_provider_and_uuid_user_details
        say "Adding migration to add provider and uuid columns to users", :green
        Bundler.with_unbundled_env do
          run "DISABLE_SPRING=1 bundle exec rails generate migration AddOmniauthToUsers provider:string uid:string"
        end
      end

      def configure_devise_omniauth
        say "Adding omniauth devise configuration", :green
        if File.exist?("config/initializers/devise.rb")
          insert_into_file "config/initializers/devise.rb", <<~RUBY, after: /Devise.setup do \|config\|/
            \n
            \tconfig.omniauth :#{@oauth_name}, "APP_ID", "APP_SECRET"
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
        say "Configuring #{@oauth_name.to_s} omniauth for user model", :green
        insert_into_file "app/models/user.rb", <<~RUBY, after: /class User < ApplicationRecord/
          \n\tdevise :omniauthable, omniauth_providers: %i[#{@oauth_name}]

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

      def show_readme
        readme "README"
      end
    end
  end
end
