# frozen_string_literal: true

require 'test_helper'
require 'generators/boring/brakeman/install/install_generator'

class AuditInstallGeneratorTest < Rails::Generators::TestCase
  tests Boring::Brakeman::InstallGenerator
  setup :build_app
  teardown :teardown_app

  include GeneratorHelper

  def destination_root
    app_path
  end

  def test_should_add_brakeman_gem
    Dir.chdir(app_path) do
      quietly { generator.add_brakeman_gem }

      assert_file "Gemfile" do |content|
        assert_match(/brakeman/, content)
      end
    end
  end

  def test_should_add_all_configurations_for_brakeman
    Dir.chdir(app_path) do
      quietly { run_generator }

      assert_file 'config/brakeman.yml' do |content|
        assert_match(/- reports\/brakeman\.json/, content)
        assert_match(/- reports\/brakeman\.html/, content)
      end

      assert_file '.github/workflows/ci.yml' do |content|
        assert_match(/name: CI/, content)
        assert_match(/- name: Scan for security vulnerabilities/, content)
        assert_match(/run: bundle exec brakeman/, content)
      end

      assert_file '.gitlab-ci.yml' do |content|
        assert_match(/stage: scan/, content)
        assert_match(/- bundle exec brakeman/, content)
      end
    end
  end

  def test_should_skip_configurations_for_brakeman
    Dir.chdir(app_path) do
      quietly { run_generator [destination_root, "--skip_config"] }

      assert_file '.github/workflows/ci.yml'
      assert_file '.gitlab-ci.yml'

      assert_no_file 'config/brakeman.yml'
    end
  end

  def test_should_skip_github_actions_configurations_for_brakeman
    Dir.chdir(app_path) do
      quietly { run_generator [destination_root, "--skip_github"] }

      assert_file 'config/brakeman.yml'
      assert_file '.gitlab-ci.yml'

      assert_no_file '.github/workflows/ci.yml'
    end
  end

  def test_should_skip_gitlab_ci_configurations_for_brakeman
    Dir.chdir(app_path) do
      quietly { run_generator [destination_root, "--skip_gitlab"] }

      assert_file 'config/brakeman.yml'
      assert_file '.github/workflows/ci.yml'

      assert_no_file '.gitlab-ci.yml'
    end
  end
end
