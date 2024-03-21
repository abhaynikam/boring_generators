# frozen_string_literal: true

module Boring
  module Rswag
    class InstallGenerator < Rails::Generators::Base
      desc "Adds rswag gem to the application"
      source_root File.expand_path("templates", __dir__)

      class_option :rails_port,
                   type: :string,
                   desc: "Tell us the port number where you normally run your rails app. Defaults to PORT 3000",
                   default: "3000"
      class_option :authentication_type,
                   type: :string,
                   desc: "Tell us the authentication type you use in your rails app. Options: ['basic', 'bearer', 'api_key']. Defaults to 'basic'",
                   default: 'basic'
      class_option :skip_api_authentication,
                   type: :boolean,
                   desc: "Use this option with value 'true' if you don't want to add Authentication when making API calls via swagger docs.",
                   default: false
      class_option :api_authentication_options,
                   type: :hash,
                   desc: 'Use together with authentication_type. Required for "api_key" authentication which has dynamic set of options. See: https://swagger.io/docs/specification/authentication. Example: "--api_authentication_options=name:api_key in:header"'
      class_option :enable_swagger_ui_authentication,
                   type: :boolean,
                   desc: "Use this option with value 'true' for securing your API docs behind a basic authentication to block unauthorized access",
                   default: false

      def verify_presence_of_rspec_gem
        gem_file_content_array = File.readlines("Gemfile")

        rspec_is_installed = gem_file_content_array.any? { |line| line.include?("rspec-rails") }

        return if rspec_is_installed

        say "We couldn't find rspec-rails gem which is a dependency for the rswag gem. Please configure rspec and run the generator again!"

        abort
      end

      def add_rswag_gems
        say "Adding rswag gems to Gemfile", :green

        gem 'rswag-api'
        gem 'rswag-ui'
        gem 'rswag-specs', group: [:development, :test]
      end

      def install_rswag
        say "\nRunning rswag install generator to add required files", :green

        Bundler.with_unbundled_env do
          run 'bundle install'

          generate 'rswag:api:install'
          generate 'rswag:ui:install'
          generate 'rswag:specs:install', [env: 'test']
        end
      end

      def update_api_host
        say "\nUpdating API Host URL", :green

        rails_port = options[:rails_port]

        gsub_file "spec/swagger_helper.rb",
                  "url: 'https://{defaultHost}'",
                  "url: 'http://{defaultHost}'"
        gsub_file "spec/swagger_helper.rb",
                  "default: 'www.example.com'",
                  "default: 'localhost:#{rails_port}'"
      end

      def add_authentication_scheme
        if options[:skip_api_authentication]
          return
        end

        say "\nAdding Authentication for APIs", :green

        authentication_type = options[:authentication_type]

        if authentication_type == 'api_key'
          validate_api_authentication_options

          authentication_options = options[:api_authentication_options]
        end

        authentication_content = case authentication_type
        when 'bearer'
          <<~RUBY.chomp.indent(0)
            type: :http,
            scheme: :bearer
          RUBY
        when 'api_key'
          <<~RUBY
            type: :apiKey,
            name: "#{authentication_options['name']}",
            in: "#{authentication_options['in']}",
          RUBY
        else
          <<~RUBY
            type: :http,
            scheme: :basic
          RUBY
        end

        gsub_file "spec/swagger_helper.rb",
                  /servers: \[.*\]/m do |match|
          configuration_content = <<~RUBY.indent(6)
          components: {
            securitySchemes: {
              authorization: {\n#{authentication_content.chomp.indent(6)}
              }
            }
          },
          security: [
            authorization: []
          ]
          RUBY

          match << ",\n#{configuration_content.chomp}"
        end
      end

      def enable_swagger_ui_authentication
        return unless options[:enable_swagger_ui_authentication]

        say "\nAdding Basic Authentication to secure the UI", :green

        uncomment_lines 'config/initializers/rswag_ui.rb', /c.basic_auth_enabled/
        uncomment_lines 'config/initializers/rswag_ui.rb', /c.basic_auth_credentials/
        gsub_file "config/initializers/rswag_ui.rb",
                  "c.basic_auth_credentials 'username', 'password'",
                  'c.basic_auth_credentials Rails.application.credentials.dig(:swagger_ui, :username), Rails.application.credentials.dig(:swagger_ui, :password)'

        say "❗️❗️\nusername will be used from `Rails.application.credentials.dig(:swagger_ui, :username)` and password from `Rails.application.credentials.dig(:swagger_ui, :password)`. You can change these values if they don't match with your app.\n", :yellow
      end

      def show_readme
        readme "README"
      end

      private

      def validate_api_authentication_options
        api_authentication_options = options[:api_authentication_options]

        if api_authentication_options.blank?
          say "api_authentication_options args should be provided for api_key authentication", :red

          abort
        end

        missing_options = %w[name in] - api_authentication_options.keys

        if missing_options.length.positive?
          say "Option/s '#{missing_options.join(', ')}' should be present for api_key authentication!", :red
          say 'Example of valid options: "--api_authentication_options=name:api_key in:query"', :yellow

          abort
        end
      end
    end
  end
end
