# frozen_string_literal: true

module Boring
  module Jquery
    class InstallGenerator < Rails::Generators::Base
      desc "Adds JQuery to the application"

      def add_jquery_package
        say "Adding JQuery packages", :green
        run "yarn add jquery"
      end

      def add_jquery_plugin_provider_to_webpack_environment
        say "Initailizing tailwind configuration", :green
        if File.exist?("config/webpack/environment.js")
          insert_into_file "config/webpack/environment.js", <<~RUBY, after: /@rails\/webpacker.*\n/
            const webpack = require("webpack")

            environment.plugins.append("Provide", new webpack.ProvidePlugin({
              $: 'jquery',
              jQuery: 'jquery'
            }))
          RUBY
        else
          say <<~WARNING, :red
            ERROR: Looks like the webpacker installation is incomplete. Could not find environment.js in config/webpack.
          WARNING
        end
      end
    end
  end
end