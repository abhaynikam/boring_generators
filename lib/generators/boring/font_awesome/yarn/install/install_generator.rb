# frozen_string_literal: true

module Boring
  module FontAwesome
    module Yarn
      class InstallGenerator < Rails::Generators::Base
        source_root File.expand_path("templates", __dir__)
        desc "Adds fontawesome via rubygems to the application"

        def add_font_awesome_package
          say "Adding fontawesome packages", :green
          run "yarn add @fortawesome/fontawesome-free"
        end

        def import_font_awesome_stylesheet
          say "Adding font awesome stylesheets", :green
          if File.exist?("app/javascript/stylesheets/application.scss")
            stylesheet_font_awesome_imports = <<~RUBY
              \n
              @import '@fortawesome/fontawesome-free';
            RUBY

            append_to_file "app/javascript/stylesheets/application.scss", stylesheet_font_awesome_imports
          else
            say "Copying application.scss with FontAwesome imports", :green
            template("application.scss", "app/javascript/stylesheets/application.scss")
          end
        end

        def import_font_awesome_javascript
          if File.exist?("app/javascript/packs/application.js")
            javascript_font_awesome_imports = <<~RUBY
              \n
              import "@fortawesome/fontawesome-free/js/all"
            RUBY

            append_to_file "app/javascript/packs/application.js", javascript_font_awesome_imports
          else
            say <<~WARNING, :red
              ERROR: Looks like the webpacker installation is incomplete. Could not find application.js in app/javascript/packs.
            WARNING
          end
        end

        def insert_stylesheet_packs_tag
          insert_into_file "app/views/layouts/application.html.erb", <<~RUBY, after: /stylesheet_link_tag.*\n/
            \t\t<%= stylesheet_pack_tag 'application', 'data-turbolinks-track': 'reload' %>
          RUBY
        end
      end
    end
  end
end
