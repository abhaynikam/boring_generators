# frozen_string_literal: true

require 'bundler'

module Boring
  module Overcommit
    class BaseGenerator < Rails::Generators::Base
      desc "Adds and configures overcommit gem in the application"

      class_option :skip_configuration,
                   type: :boolean, aliases: "-s",
                   desc: "Skips adding overcommit development configuration"

      def add_overcommit_gem
        say "Adding overcommit gem", :green

        if overcommit_gem_exists?
          say "Overcommit gem is already installed!", :yellow
        else
          Bundler.with_unbundled_env do
            run "bundle add overcommit --group development,test"
          end
        end
      end

      def add_git_hooks_with_overcommit
        return if options[:skip_configuration]

        say "\nInstalling git hooks to your project", :green

        Bundler.with_unbundled_env do
          run "bundle exec overcommit --install"
        end
      end

      private

      def overcommit_gem_exists?
        gem_file_content_array = File.readlines("Gemfile")

        gem_file_content_array.any? { |line| line.include?("overcommit") }
      end
    end
  end
end
