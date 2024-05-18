# frozen_string_literal: true

require "generators/boring/pronto/base_generator"
require "boring_generators/generator_helper"

module Boring
  module Pronto
    module GitlabCi
      class InstallGenerator < Boring::Pronto::BaseGenerator
        desc "Adds Pronto gem with various extensions and configures it for Gitlab CI"
        source_root File.expand_path("templates", __dir__)

        class_option :ruby_version, type: :string, aliases: "-rv"

        include BoringGenerators::GeneratorHelper

        def add_configuration
          @ruby_version = options.ruby_version || app_ruby_version

          if File.exists?(".gitlab-ci.yml")
            add_configuration_to_existing_file
            add_lint_stage_to_existing_file
            show_readme
          else
            say "Creating .gitlab-ci.yml with Pronto configurations",
                :yellow

            template ".gitlab-ci.yml", ".gitlab-ci.yml"
          end
        end

        private

        def add_configuration_to_existing_file
          if gitlab_ci_file_content["pronto"]
            say "Skipping Pronto configurations",
                :yellow

            return
          end
          
          say "Adding Pronto configurations to .gitlab-ci.yml", :green

          ci_file_content = <<~RUBY
            pronto:
              image: ruby:#{@ruby_version}
              stage: lint
              only:
                # run pronto on merge requests and when new changes are pushed to it
                - merge_requests
              variables:
                PRONTO_GITLAB_API_PRIVATE_TOKEN: $PRONTO_ACCESS_TOKEN
              before_script:
                  # Install cmake required for rugged gem (Pronto depends on it)
                  - apt-get update && apt-get install -y cmake
                  # use bundler version same as the one that bundled the Gemfile
                  - gem install bundler -v "$(grep -A 1 "BUNDLED WITH" Gemfile.lock | tail -n 1)" --no-document
                  - bundle install --jobs $(nproc)
              script:
                # Pronto fails with the error "revspec 'origin/{target_branch}' because Gitlab fetches changes with git depth set to 20 by default. You can remove this line if you update Gitlab CI setting to clone the full project.
                - git fetch origin $CI_MERGE_REQUEST_TARGET_BRANCH_NAME
                # Run pronto on branch of current merge request
                - bundle exec pronto run -f gitlab_mr -c origin/$CI_MERGE_REQUEST_TARGET_BRANCH_NAME
          RUBY

          inject_into_file ".gitlab-ci.yml",
                           "\n#{ci_file_content}\n",
                           before: /\Z/
        end

        def add_lint_stage_to_existing_file
          ci_file_content =
            YAML.safe_load(File.open(".gitlab-ci.yml"), aliases: true) || {}

          if gitlab_ci_file_content["stages"] &&
               gitlab_ci_file_content["stages"].include?("lint")
            return
          end

          if ci_file_content["stages"]
            inject_into_file ".gitlab-ci.yml",
                             optimize_indentation("\n- lint", 2).chomp,
                             after: /stages:/
          else
            stages_configuration = <<~RUBY
              stages:
                - lint
            RUBY

            inject_into_file ".gitlab-ci.yml",
                             "#{stages_configuration}\n",
                             before: /pronto:/
          end
        end

        def show_readme
          readme "README"
        end

        def gitlab_ci_file_content
          return @gitlab_ci_file_content if defined?(@gitlab_ci_file_content)

          @gitlab_ci_file_content =
            YAML.safe_load(File.open(".gitlab-ci.yml"), aliases: true) || {}
        end
      end
    end
  end
end
