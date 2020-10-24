# frozen_string_literal: true

require 'bundler'

module Boring
  module Pundit
    class InstallGenerator < Rails::Generators::Base
      desc "Adds pundit to the application"

      def add_pundit_gem
        say "Adding Pundit gem", :green

        Bundler.with_unbundled_env do
          run "bundle add pundit"
        end
      end

      def run_pundit_generator
        return if options[:skip_generator]

        say "Running Pundit Generator", :green
        run "DISABLE_SPRING=1 rails generate pundit:install"
      end

      def inject_pundit_to_controller
        say "Adding Pundit module into ApplicationController", :green
        inject_into_file 'app/controllers/application_controller.rb', after: "class ApplicationController < ActionController::Base\n" do
          "  include Pundit\n"
        end
      end

      def ensure_policies
        return if options[:skip_ensuring_policies]

        say "Force ensuring policies", :green
        inject_into_file 'app/controllers/application_controller.rb', after: "include Pundit\n" do
          "  after_action :verify_authorized\n"
        end
      end

      def rescue_from_not_authorized
        return if options[:skip_rescue]

        say "Add rescue from Pundit::NotAuthorizedError", :green

        after = if File.read('app/controllers/application_controller.rb') =~ (/:verify_authorized/)
                  "after_action :verify_authorized\n"
                else
                  "include Pundit\n"
                end

        inject_into_file 'app/controllers/application_controller.rb', after: after do
          <<~RUBY
            rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

            private

            def user_not_authorized
              flash[:alert] = "You are not authorized to perform this action."
              redirect_to(request.referrer || root_path)
            end
          RUBY
        end
      end

      def after_run
        unless options[:skip_rescue]
          say "\nPlease check the `application_controller.rb` file and fix any potential issues"
        end

        say "\nDon't forget, that you can generate policies with \nrails g pundit:policy Model\n"
      end
    end
  end
end
