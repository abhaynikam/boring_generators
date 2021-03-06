# frozen_string_literal: true

module Boring
  module FontAwesome
    module RubyGem
      class InstallGenerator < Rails::Generators::Base
        desc "Adds fontawesome via yarn to the application"

        def add_font_awesome_sass_gem
          say "Adding font_awesome_sass gem", :green
          Bundler.with_unbundled_env do
            run "bundle add font-awesome-sass"
          end
        end

        def import_font_awesome_stylesheet
          say "Adding font awesome stylesheets", :green
          stylesheet_font_awesome_imports = <<~RUBY
            \n
            @import "font-awesome-sprockets";
            @import "font-awesome";
          RUBY

          if File.exist?("app/assets/stylesheets/application.css.scss")
            append_to_file "app/assets/stylesheets/application.css.scss", stylesheet_font_awesome_imports
          elsif File.exist?("app/assets/stylesheets/application.scss")
            append_to_file "app/assets/stylesheets/application.scss", stylesheet_font_awesome_imports
          else
            say <<~WARNING, :red
              ERROR: Looks like the application.css.scss is missing. Please rename the file and re-run the generator.
            WARNING
          end
        end
      end
    end
  end
end
