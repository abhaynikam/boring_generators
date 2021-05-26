# frozen_string_literal: true

module Boring
  module Pry
    class InstallGenerator < Rails::Generators::Base
      desc "Adds pry to the application"
      source_root File.expand_path("templates", __dir__)

      def add_bullet_gem
        say "Adding pry gems", :green
        Bundler.with_unbundled_env do
          run "bundle add pry pry-rails"
        end
      end

      def add_pryrc_configuration
        return if options[:skip_configuration]

        say "Copying pryrc configuration", :green
        template("pryrc", ".pryrc")
      end
    end
  end
end
