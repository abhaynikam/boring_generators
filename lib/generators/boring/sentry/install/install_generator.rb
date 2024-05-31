# frozen_string_literal: true

module Boring
  module Sentry
    class InstallGenerator < Rails::Generators::Base
      source_root File.expand_path("templates", __dir__)
      desc 'Adds Sentry to the app'

      class_option :use_env_variable, type: :boolean, aliases: '-ev',
                   desc: 'Use ENV variable for Sentry. By default Rails credentials will be used.' 
      class_option :breadcrumbs_logger, type: :array, aliases: '-bl', default: [:active_support_logger, :http_logger],
                   desc: 'Set the breadcrumbs logger. By default [:active_support_logger, :http_logger] will be used.'

      def add_sentry_gems
        say 'Adding Sentry gem', :green

        Bundler.with_unbundled_env do
          run 'bundle add sentry-ruby sentry-rails'
        end
      end

      def configure_sentry_gem
        say 'Configuring Sentry gem', :green

        @sentry_dsn_key = sentry_dsn_key
        @breadcrumbs_logger_options = options[:breadcrumbs_logger].map(&:to_sym)

        template 'sentry.rb', 'config/initializers/sentry.rb'

        show_alert_message
      end

      private

      def sentry_dsn_key
        if options[:use_env_variable]
          "ENV['SENTRY_DSN_KEY']"
        else
          "Rails.application.credentials.dig(:sentry, :dsn_key)"
        end
      end

      def show_alert_message
        say "❗️❗️\nThe DSN key for Sentry will be used from `#{sentry_dsn_key}`. You can change this value if it doesn't match with your app.\n", :yellow
      end
    end
  end
end
