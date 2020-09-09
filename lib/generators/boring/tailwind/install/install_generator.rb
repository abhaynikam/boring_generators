# frozen_string_literal: true

module Boring
  module Tailwind
    class InstallGenerator < Rails::Generators::Base
      desc "Adds Tailwind CSS to the application"
      source_root File.expand_path("templates", __dir__)

      class_option :skip_tailwind_css_ui,    type: :boolean, aliases: "-sui",
                                            desc: "Skip adding @tailwindcss/ui package"
      class_option :skip_tailwind_init_full, type: :boolean, aliases: "-sif",
                                            desc: "Skip running tailwindcss init with --full option"

      def add_tailwind_package
        say "Adding tailwind package", :green
        if options[:skip_tailwind_css_ui]
          run "yarn add tailwindcss"
        else
          run "yarn add tailwindcss @tailwindcss/ui"
        end
      end

      def create_tailwind_config
        say "Initailizing tailwind configuration", :green
        if options[:skip_tailwind_init_full]
          run "yarn tailwindcss init"
        else
          run "yarn tailwindcss init --full"
        end
      end

      def include_tailwind_to_postcss_config
        insert_into_file "postcss.config.js", <<~RUBY, after: /plugins:\s+\[\n/
          \t\trequire('tailwindcss'),
        RUBY
      end

      def add_or_import_stylesheet_for_tailwind
        if File.exist?("app/javascript/stylesheets/application.scss")
          say "Add TailwindCSS imports to the application.scss", :green
          stylesheet_tailwind_imports = <<~RUBY
            \n
            @import "tailwindcss/base";
            @import "tailwindcss/components";
            @import "tailwindcss/utilities";
          RUBY

          append_to_file "app/javascript/stylesheets/application.scss", stylesheet_tailwind_imports
        else
          say "Copying application.scss with Tailwind imports", :green
          template("application.scss", "app/javascript/stylesheets/application.scss")
        end
      end

      def insert_stylesheet_in_the_application
        if File.exist?("app/javascript/packs/application.js")
          append_to_file "app/javascript/packs/application.js" do
            'import "stylesheets/application"'
          end
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