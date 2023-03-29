# frozen_string_literal: true

require "generators/boring/overcommit/base_generator"

module Boring
  module Overcommit
    module PreCommit
      module Rubocop
        class InstallGenerator < Boring::Overcommit::BaseGenerator
          def configure_rubocop
            unless rubocop_gem_exists?
              say "\nrubocop gem is not installed. Please install it and run the generator again!", :red

              return
            end

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
