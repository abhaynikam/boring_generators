# frozen_string_literal: true

require "generators/boring/overcommit/base_generator"

module Boring
  module Overcommit
    module PreCommit
      module Rubocop
        class InstallGenerator < Boring::Overcommit::BaseGenerator
          DEFAULT_RUBY_VERSION = "2.7.1"

          class_option :ruby_version, type: :string, aliases: "-v",
                       desc: "Tell us the ruby version you use for the application. Defaults to Ruby #{DEFAULT_RUBY_VERSION}"

          def check_and_install_rubocop
            return if rubocop_gem_exists?

            say "\nRuboCop gem is not installed. Running the generator to install it!\n", :red

            ruby_version = options[:ruby_version].presence || DEFAULT_RUBY_VERSION

            run "bundle exec rails generate boring:rubocop:install --ruby_version=#{ruby_version}"
          end

          def configure_rubocop
            say "\nAdding configurations for running RuboCop on pre-commit", :green

            uncomment_lines(".overcommit.yml", /PreCommit:/)

            gsub_file(".overcommit.yml", /PreCommit:/) do
              <<~YAML
                PreCommit:
                  RuboCop:
                    enabled: true
                    on_warn: fail # Treat all warnings as failures
                    problem_on_unmodified_line: ignore # run RuboCop only on modified code'
              YAML
            end
          end

          def enable_overcommit_configurations
            say "\nEnabling new configurations", :green

            run "git add .overcommit.yml"

            Bundler.with_unbundled_env do
              run "bundle exec overcommit --sign"
            end
          end

          private

          def rubocop_gem_exists?
            gem_file_content_array = File.readlines("Gemfile")

            gem_file_content_array.any? { |line| line.include?("rubocop") }
          end
        end
      end
    end
  end
end
