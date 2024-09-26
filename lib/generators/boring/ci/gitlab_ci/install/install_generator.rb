# frozen_string_literal: true

require "boring_generators/generator_helper"

module Boring
  module Ci
    module GitlabCi
      class InstallGenerator < Rails::Generators::Base
        desc "Adds Gitlab CI to the application"
        source_root File.expand_path("templates", __dir__)

        class_option :ruby_version,
                     aliases: "-rv",
                     type: :string,
                     desc:
                       "Ruby version used by your app. Defaults to .ruby_version or the version specified in your Gemfile."
        class_option :app_test_framework,
                     aliases: "-tf",
                     type: :string,
                     enum: %w[minitest rspec],
                     default: "minitest",
                     desc:
                       "Tell us the test framework you use for the application. Defaults to Minitest."
        class_option :environment_variable_manager,
                     aliases: "-evm",
                     type: :string,
                     enum: %w[rails_credentials dotenv figjam],
                     default: "rails_credentials",
                     desc:
                       "Tell us the environment variable manager you use. Defaults to Rails Credentials"
        class_option :database,
                     aliases: "-d",
                     type: :string,
                     enum: %w[sqlite3 postgresql mysql],
                     default: "sqlite3",
                     desc: "Tell us the database you use in your app"
        class_option :skip_sample_tests,
                     aliases: "-stt",
                     type: :boolean,
                     default: false,
                     desc:
                       "Skip sample tests. Useful when you are configuring Gitlab CI for existing Rails app"

        include BoringGenerators::GeneratorHelper

        def add_gitlab_ci_configurations
          @ruby_version = options[:ruby_version] || app_ruby_version
          @app_test_framework = options[:app_test_framework]
          @environment_variable_manager = options[:environment_variable_manager]
          @database = options[:database]

          template("ci.yml", ".gitlab-ci.yml")
          template("database.yml.ci", "config/database.yml.ci")
        end

        def add_gems_for_system_test
          check_and_install_gem "capybara", group: :test
          check_and_install_gem "selenium-webdriver", group: :test
        end

        def add_capybara_configurations
          if options[:app_test_framework] == "minitest"
            template("capybara_helper.rb", "test/helpers/capybara.rb")

            inject_into_file_if_new "test/application_system_test_case.rb",
                                    "require \"helpers/capybara\"\n",
                                    before: "class ApplicationSystemTestCase"
            gsub_file "test/application_system_test_case.rb",
                      /driven_by :selenium, using: :(?:chrome|headless_chrome).*\n/,
                      "driven_by :selenium_chrome_custom"

            capybara_setup = <<-RUBY
            \n
            def setup
              Capybara.server_host = "0.0.0.0" # bind to all interfaces
              Capybara.server_port = 3000

              if ENV["SELENIUM_REMOTE_URL"].present?
                ip = Socket.ip_address_list.detect(&:ipv4_private?).ip_address
                Capybara.app_host = "http://\#{ip}:\#{Capybara.server_port}"
              end

              super
            end
            RUBY

            inject_into_file_if_new "test/application_system_test_case.rb",
                                    optimize_indentation(
                                      capybara_setup,
                                      amount = 2
                                    ),
                                    after: "driven_by :selenium_chrome_custom"
          else
            template("capybara_helper.rb", "spec/support/capybara.rb")

            inject_into_file_if_new "spec/rails_helper.rb",
                                    "require_relative \"./support/capybara\"\n\n",
                                    before: "RSpec.configure do |config|"
          end
        end

        def add_sample_tests
          return if options[:skip_sample_tests]

          if options[:app_test_framework] == "minitest"
            template("unit_sample_test.rb", "test/models/sample_test.rb")
            template("system_sample_test.rb", "test/system/sample_test.rb")
          else
            template("unit_sample_spec.rb", "spec/models/sample_spec.rb")
            template("system_sample_spec.rb", "spec/system/sample_spec.rb")
          end
        end

        def show_readme
          readme "README"
        end
      end
    end
  end
end
