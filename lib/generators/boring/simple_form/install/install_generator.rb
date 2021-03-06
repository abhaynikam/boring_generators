# frozen_string_literal: true

module Boring
  module SimpleForm
    class InstallGenerator < Rails::Generators::Base
      desc "Adds SimpleForm to the application"
      source_root File.expand_path("templates", __dir__)

      class_option :css_framework, type: :string, aliases: "-css",
                   desc: "Skip before_action to ensure user is authorized"
      class_option :skip_generator, type: :boolean, aliases: "-sg",
                   desc: "Skip running Pundit install generator"

      ALLOWED_CSS_FRAMEWORK = %w(bootstrap foundation)

      def add_bullet_gem
        say "Adding SimpleForm gem", :green
        Bundler.with_unbundled_env do
          run "bundle add simple_form"
        end
      end

      def run_simple_form_generator
        return if options[:skip_generator]

        say "Running SimpleForm Generator", :green
        if options[:css_framework].present? && ALLOWED_CSS_FRAMEWORK.include?(options[:css_framework])
          run "DISABLE_SPRING=1 bundle exec rails generate simple_form:install --#{options[:css_framework]}"
        elsif options[:css_framework].present?
          say <<~WARNING, :red
            ERROR: Invalid option css_framework: #{options[:css_framework]}. Generator allows css_framework: #{ALLOWED_CSS_FRAMEWORK.join(", ")}
          WARNING
        else
          run "rails generate simple_form:install"
        end
      end
    end
  end
end

