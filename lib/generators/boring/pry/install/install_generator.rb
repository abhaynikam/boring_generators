# frozen_string_literal: true

module Boring
  module Pry
    class InstallGenerator < Rails::Generators::Base
      desc "Adds pry to the application"
      source_root File.expand_path("templates", __dir__)

      def add_bullet_gem
        say "Adding Bullet gem", :green
        pry_gem_content = <<~RUBY
          \n
          # for using pry as Rails console
          gem "pry"
          gem "pry-rails"
        RUBY
        append_to_file "Gemfile", pry_gem_content
        run "bundle install"
      endgst

      def add_pryrc_configuration
        return if options[:skip_configuration]

        say "Copying pryrc configuration", :green
        template("pryrc", ".pryrc")
      end
    end
  end
end
