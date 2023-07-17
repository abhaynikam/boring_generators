# frozen_string_literal: true

module Boring
  module DatabaseCleaner
    module ActiveRecord
      module Rspec
        class InstallGenerator < Rails::Generators::Base
          desc 'Adds database_cleaner-active_record gem to the application for cleaning databases during tests'
          source_root File.expand_path("templates", __dir__)

          TEST_FRAMEWORK_GEM = 'rspec-rails'

          class_option :skip_capybara_configs, type: :boolean,
                                               aliases: "-sc",
                                               desc: "Skip Capybara config"

          def verify_presence_of_rspec_gem
            gem_file_content_array = File.readlines("Gemfile")
            rspec_is_installed = gem_file_content_array.any? { |line| line.include?(TEST_FRAMEWORK_GEM) }

            return if rspec_is_installed

            say "We couldn't find #{TEST_FRAMEWORK_GEM} gem. Please configure #{TEST_FRAMEWORK_GEM} and run the generator again!", :red

            abort
          end

          def verify_presence_of_rails_helper
            return if File.exist?("spec/rails_helper.rb")

            say "We couldn't find spec/rails_helper.rb. Please configure RSpec and run the generator again!", :red

            abort
          end

          def add_database_cleaner_active_record_gem
            say 'Adding database_cleaner-active_record gem', :green

            Bundler.with_unbundled_env do
              run "bundle add database_cleaner-active_record --group='test'"
            end
          end

          def configure_database_cleaner
            @skip_capybara_configs = options[:skip_capybara_configs]

            unless @skip_capybara_configs
              rails_helper_content = File.read("spec/rails_helper.rb")
              if rails_helper_content.match?(/config.use_transactional_fixtures = true/)
                disable_transactional_fixtures
              end
            end

            template("database_cleaner.rb", "spec/support/database_cleaner.rb")

            inject_into_file 'spec/rails_helper.rb',
                             "require 'support/database_cleaner'\n\n",
                             before: /\A/
          end

          private

          def disable_transactional_fixtures
            say "Disabling transactional fixtures to prevent uncommitted transactions being used in JavaScript-dependent specs.", :yellow
            gsub_file "spec/rails_helper.rb",
                      "config.use_transactional_fixtures = true",
                      "config.use_transactional_fixtures = false"

          end
        end
      end
    end
  end
end
