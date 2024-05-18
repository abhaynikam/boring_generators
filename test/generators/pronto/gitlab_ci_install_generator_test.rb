# frozen_string_literal: true

require "test_helper"
require "generators/boring/pronto/gitlab_ci/install/install_generator"

class ProntoGitlabCiInstallGeneratorTest < Rails::Generators::TestCase
  tests Boring::Pronto::GitlabCi::InstallGenerator
  setup :build_app
  teardown :teardown_app

  include GeneratorHelper
  include ActiveSupport::Testing::Isolation

  def destination_root
    app_path
  end

  def test_should_configure_pronto_in_new_gitlab_ci_file
    Dir.chdir(app_path) do
      quietly { run_generator }

      template_app_ruby_version = `cat .ruby-version`

      assert_file ".gitlab-ci.yml" do |content|
        assert_match("stages:", content)
        assert_match("pronto:", content)
        assert_match("image: ruby:#{template_app_ruby_version}", content)
      end
    end
  end

  def test_should_configure_pronto_in_existing_gitlab_ci_file
    Dir.chdir(app_path) do
      create_gitlab_ci_file

      quietly { run_generator }

      template_app_ruby_version = `cat .ruby-version`
      stages_configuration = <<~RUBY
        stages:
          - lint
      RUBY

      assert_file ".gitlab-ci.yml" do |content|
        assert_match(stages_configuration, content)
        assert_match("pronto:", content)
        assert_match("image: ruby:#{template_app_ruby_version}", content)
      end
    end
  end

  def test_should_add_correct_ruby_image
    Dir.chdir(app_path) do
      create_gitlab_ci_file

      quietly { run_generator [app_path, "--ruby_version=3.0.0"] }

      assert_file ".gitlab-ci.yml" do |content|
        assert_match("image: ruby:3.0.0", content)
      end
    end
  end

  def test_should_append_lint_to_existing_stages
    Dir.chdir(app_path) do
      create_gitlab_ci_file
      inject_stages_to_ci_file

      quietly { run_generator }

      stages_configuration = <<~RUBY
        stages:
          - lint
          - test
      RUBY

      assert_file ".gitlab-ci.yml" do |content|
        assert_match(stages_configuration, content)
      end
    end
  end

  private

  def create_gitlab_ci_file
    `touch #{app_path}/.gitlab-ci.yml`
  end

  def inject_stages_to_ci_file
    stages_configuration = <<~RUBY
      stages:
        - test
    RUBY

    `echo "#{stages_configuration}\n" >> #{app_path}/.gitlab-ci.yml`
  end
end
