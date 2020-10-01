# frozen_string_literal: true

module Boring
  module Ci
    module Circleci
      class InstallGenerator < Rails::Generators::Base
        desc "Adds Circle CI to the application"
        source_root File.expand_path("templates", __dir__)

        DEFAULT_RUBY_VERSION = "2.7.1"
        DEFAULT_REPOSITORY_NAME = "boring_generators"

        class_option :ruby_version,     type: :string, aliases: "-v",
                                                       desc: "Tell us the ruby version to which you use for the application. Default to Ruby #{DEFAULT_RUBY_VERSION}"
        class_option :skip_node,        type: :boolean, aliases: "-sn",
                                                        desc: "Skips the node configuration required for webpacker based Rails application."
        class_option :repository_name,  type: :string, aliases: "-rn",
                                                       desc: "Tell us the repository name to be used as database name on circleci. Defaults to #{DEFAULT_REPOSITORY_NAME}"

        def add_circle_ci_configuration
          @skip_node = options[:skip_node]
          @ruby_version = options[:ruby_version] ? options[:ruby_version] : DEFAULT_RUBY_VERSION
          @repository_name = options[:repository_name] ? options[:repository_name] : DEFAULT_REPOSITORY_NAME

          template("config.psql.yml", ".circleci/config.yml")
          template("database.yml.ci", "config/database.yml.ci")
        end
      end
    end
  end
end
