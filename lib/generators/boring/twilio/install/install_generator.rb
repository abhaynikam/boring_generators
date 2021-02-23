# frozen_string_literal: true

module Boring
  module Twilio
    class InstallGenerator < Rails::Generators::Base
      desc "Adds Twilio to the application"
      source_root File.expand_path("templates", __dir__)

      def add_twilio_ruby_gem
        say "Adding Twilio gem", :green
        twilio_gem_content = <<~RUBY
          \n
          # for twilio REST APIs
          gem 'twilio-ruby', '~> 5.47'
        RUBY
        append_to_file "Gemfile", twilio_gem_content
        run "bundle install"
      end

      def add_twilio_configurations
        say "Copying Twilio configuration", :green
        template("twilio.rb", "config/initializers/twilio.rb")
      end

      def show_readme
        readme "README"
      end
    end
  end
end
