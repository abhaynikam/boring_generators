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

          if File.exist?(".gitlab-ci.yml")
            add_pronto_configuration
            add_lint_stage
            show_readme
          else
            create_gitlab_ci_with_pronto
          end
        end

        private

        def create_gitlab_ci_with_pronto
          say "Creating .gitlab-ci.yml with Pronto configurations", :yellow
          template ".gitlab-ci.yml", ".gitlab-ci.yml"
        end

        def add_pronto_configuration
          return if pronto_configuration_exists?

          say "Adding Pronto configurations to .gitlab-ci.yml", :green
          inject_into_file ".gitlab-ci.yml", pronto_ci_content, before: /\Z/
        end

        def add_lint_stage
          return if lint_stage_exists?

          if stages_exists?
            inject_into_file ".gitlab-ci.yml",
                             optimize_indentation("\n- lint", 2).chomp,
                             after: /stages:/
          else
            inject_into_file ".gitlab-ci.yml",
                             stages_configuration,
                             before: /pronto:/
          end
        end

        def show_readme
          readme "README"
        end

        def pronto_configuration_exists?
          gitlab_ci_file_content["pronto"]
        end

        def lint_stage_exists?
          gitlab_ci_file_content["stages"] &&
            gitlab_ci_file_content["stages"].include?("lint")
        end

        def stages_exists?
          gitlab_ci_file_content["stages"]
        end

        def gitlab_ci_file_content
          @gitlab_ci_file_content ||=
            YAML.safe_load(File.open(".gitlab-ci.yml"), aliases: true) || {}
        end

        def pronto_ci_content
          <<~RUBY
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
        end

        def stages_configuration
          <<~RUBY
              stages:
                - lint
            RUBY
        end
      end
    end
  end
end
