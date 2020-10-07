# frozen_string_literal: true

require "test_helper"
require "generators/boring/ci/github_action/install/install_generator"

class GithubActionInstallGeneratorTest < Rails::Generators::TestCase
  tests Boring::Ci::GithubAction::InstallGenerator
  setup :build_app
  teardown :teardown_app

  include GeneratorHelper

  def destination_root
    app_path
  end

  def test_should_install_github_actions_successfully
    Dir.chdir(app_path) do
      quietly { run_generator }

      assert_file ".github/workflows/ci.yml" do |content|
        assert_match("boring_generators_test", content)
        assert_match("2.7.1", content)
        assert_match("10.13.0", content)
      end
    end
  end

  def test_generator_should_use_repository_name_passed_in_params
    Dir.chdir(app_path) do
      quietly { run_generator [destination_root, "--repository_name=boring"] }

      assert_file ".github/workflows/ci.yml" do |content|
        assert_match("boring_test", content)
      end
    end
  end

  def test_generator_should_use_ruby_version_passed_in_params
    Dir.chdir(app_path) do
      quietly { run_generator [destination_root, "--ruby_version=2.6.3"] }

      assert_file ".github/workflows/ci.yml" do |content|
        assert_match("boring_generators_test", content)
        assert_match("2.6.3", content)
      end
    end
  end

  def test_generator_should_use_node_version_passed_in_params
    Dir.chdir(app_path) do
      quietly { run_generator [destination_root, "--node_version=10.13.2"] }

      assert_file ".github/workflows/ci.yml" do |content|
        assert_match("boring_generators_test", content)
        assert_match("10.13.2", content)
      end
    end
  end
end
