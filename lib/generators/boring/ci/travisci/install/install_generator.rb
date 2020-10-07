# frozen_string_literal: true

module Boring
  module Ci
    module Travisci
      class InstallGenerator < Rails::Generators::Base
        desc "Adds Github Action to the application"
        source_root File.expand_path("templates", __dir__)

        DEFAULT_RUBY_VERSION = "2.7.1"

        class_option :ruby_version, type: :string, aliases: "-v",
                                    desc: "Tell us the ruby version which you use for the application. Default to Ruby #{DEFAULT_RUBY_VERSION}"

        def add_github_actions_configuration
          @ruby_version = options[:ruby_version] ? options[:ruby_version] : DEFAULT_RUBY_VERSION

          template(".travis.yml", ".travis.yml")
        end
      end
    end
  end
end
