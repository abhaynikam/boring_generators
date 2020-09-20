# frozen_string_literal: true

module Boring
  module Ci
    module Circleci
      class InstallGenerator < Rails::Generators::Base
        desc "Adds a generator to configure Circle CI to the application"
        source_root File.expand_path("templates", __dir__)

        class_option :skip_node,    :type => :boolean
                                    desc: "Skip adding node configuration in the circle"

        def add_circle_ci_configuration
          @skip_node = options[:skip_node]
          @ruby_version = ask "Ruby Version: ".chomp
          database_name = ask "Which Database(psql/sql): ".chomp

          if database_name.eql?("psql")
            template("config.psql.yml", "app/javascript/stylesheets/application.scss")
          elsif database_name.eql?("sql")
            template("config.psql.yml", "app/javascript/stylesheets/application.scss")
          else
            say <<~WARNING, :red
              ERROR: Boring Generators do not support to configure #{database_name} for circle yet.
            WARNING
          end
        end
      end
    end
  end
end
