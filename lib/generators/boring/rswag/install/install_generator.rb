# frozen_string_literal: true

module Boring
  module Rswag
    class InstallGenerator < Rails::Generators::Base
      DEFAULT_RAILS_PORT = '3000'

      desc "Adds rswag gem to the application"

      class_option :rails_port,
                   type: :string,
                   desc: "Tell us the port number where you normally run your rails app. Defaults to PORT #{DEFAULT_RAILS_PORT}",
                   default: DEFAULT_RAILS_PORT

      def verify_presence_of_rspec_gem
        gem_file_content_array = File.readlines("Gemfile")

        rspec_is_installed = gem_file_content_array.any? { |line| line.include?("rspec-rails") }

        return if rspec_is_installed

        say "We couldn't find rspec-rails gem which is a dependency for the rswag gem. Please configure rspec and run the generator again!"

        abort
      end

      def add_rswag_gem
        say "Adding rswag gem", :green

        run "bundle add rswag"
      end

      def run_rswag_install_generator
        say "\nRunning rswag install generator to add required files", :green

        run "bundle exec rails generate rswag:install"
      end

      def update_api_host
        say "\nUpdating API Host URL"

        rails_port = options[:rails_port]

        gsub_file "spec/swagger_helper.rb",
                  "url: 'https://{defaultHost}'",
                  "url: 'http://{defaultHost}'"
        gsub_file "spec/swagger_helper.rb",
                  "default: 'www.example.com'",
                  "default: 'localhost:#{rails_port}'"
      end

      def show_whats_next_message
        say "\nNow that you have rswag installed, what's next? You could do the following:", :green

        help_text = <<~TEXT
          1. Write a rswag spec by following instructions from Getting Started guide at https://github.com/rswag/rswag#getting-started
          2. Once the spec is ready, generate the swagger file with `rails rswag`
          3. Run the rails server with `rails s`
          4. Assuming your app is at "localhost:3000", you will find your API docs at `http://localhost:3000/api-docs/index.html`
        TEXT

        say "\n#{help_text}", :yellow
      end

      def show_additional_configurations_message
        say "\nYou are now ready to develop your API documentation locally but for making it production ready, you might need to add more configurations. Following guides can help you:", :green

        help_text = <<~TEXT
          1. Enable API Authentication => https://github.com/rswag/rswag/tree/2.8.0#specifyingtesting-api-security
          2. Support multiple API version documentation => https://github.com/rswag/rswag/tree/2.8.0#global-metadata
          3. Enable Basic Authentication for Swagger UI => https://github.com/rswag/rswag/tree/2.8.0#enable-simple-basic-auth-for-swagger-ui
        TEXT

        say "\n#{help_text}", :yellow
      end
    end
  end
end
