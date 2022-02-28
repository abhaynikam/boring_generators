# frozen_string_literal: true

module Boring
  module Bootstrap
    class InstallGenerator < Rails::Generators::Base
      desc "Adds Bootstrap to the application"
      source_root File.expand_path("templates", __dir__)

      def add_bootstrap_package
        say "Adding bootstrap packages", :green
        run "yarn add bootstrap jquery @popperjs/core"
      end

      def add_jquery_plugin_provider_to_webpack_environment
        say "Adding jQuery and popper JS plugin in the webpack", :green
        if File.exist?("config/webpack/environment.js")
          insert_into_file "config/webpack/environment.js", <<~RUBY, after: /@rails\/webpacker.*\n/
            const webpack = require("webpack")

            environment.plugins.append("Provide", new webpack.ProvidePlugin({
              $: 'jquery',
              jQuery: 'jquery',
              Popper: ['popper.js', 'default']
            }))
          RUBY
        else
          say <<~WARNING, :red
            ERROR: Looks like the webpacker installation is incomplete. Could not find environment.js in config/webpack.
          WARNING
        end
      end

      def add_or_import_stylesheet_for_bootstrap
        if File.exist?("app/javascript/stylesheets/application.scss")
          say "Add bootstrap imports to the application.scss", :green
          append_to_file "app/javascript/stylesheets/application.scss" do
            '@import "~bootstrap/scss/bootstrap";'
          end
        else
          say "Copying application.scss with bootstrap imports", :green
          template("application.scss", "app/javascript/stylesheets/application.scss")
        end
      end

      def insert_stylesheet_in_the_application
        if File.exist?("app/javascript/packs/application.js")
          application_js_content = <<~RUBY
            \n
            import "bootstrap"
            import "stylesheets/application"
            import { Tooltip, Popover } from "bootstrap"

            document.addEventListener("turbolinks:load", () => {
              // Both of these are from the Bootstrap 5 docs
              var tooltipTriggerList = [].slice.call(document.querySelectorAll('[data-bs-toggle="tooltip"]'))
              var tooltipList = tooltipTriggerList.map(function(tooltipTriggerEl) {
                  return new Tooltip(tooltipTriggerEl)
              })

              var popoverTriggerList = [].slice.call(document.querySelectorAll('[data-bs-toggle="popover"]'))
              var popoverList = popoverTriggerList.map(function(popoverTriggerEl) {
                  return new Popover(popoverTriggerEl)
              })
            })
          RUBY
          append_to_file "app/javascript/packs/application.js", application_js_content
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