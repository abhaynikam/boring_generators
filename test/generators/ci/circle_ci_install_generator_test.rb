# frozen_string_literal: true

require "test_helper"
require "generators/boring/ci/circleci/install/install_generator"

class CircleCiInstallGeneratorTest < Rails::Generators::TestCase
  tests Boring::Ci::Circleci::InstallGenerator
  setup :build_app
  teardown :teardown_app

  include GeneratorHelper

  def destination_root
    app_path
  end

  def test_generator_should_install_circle_ci_successfully
    Dir.chdir(app_path) do
      quietly { run_generator }

      assert_file ".circleci/config.yml" do |content|
        assert_match("boring_generators_test", content)
        assert_match("2.7.1-node", content)
        assert_match("circleci/ruby@1.1.1", content)
        assert_match("circleci/node@2", content)
      end

      assert_file "config/database.yml.ci" do |content|
        assert_match("boring_generators_test", content)
      end
    end
  end

  def test_generator_should_skip_adding_node_configuration_params
    Dir.chdir(app_path) do
      quietly { run_generator [destination_root, "--skip-node"] }

      assert_file ".circleci/config.yml" do |content|
        assert_no_match("circleci/node@2", content)
      end
    end
  end

  def test_generator_should_use_repository_name_passed_in_params
    Dir.chdir(app_path) do
      quietly { run_generator [destination_root, "--repository_name=boring"] }

      assert_file ".circleci/config.yml" do |content|
        assert_match("boring_test", content)
      end

      assert_file "config/database.yml.ci" do |content|
        assert_match("boring_test", content)
      end
    end
  end

  def test_generator_should_use_ruby_version_passed_in_params
    Dir.chdir(app_path) do
      quietly { run_generator [destination_root, "--ruby_version=2.6.3"] }

      assert_file ".circleci/config.yml" do |content|
        assert_match("boring_generators_test", content)
        assert_match("2.6.3-node", content)
        assert_match("circleci/ruby@1.1.1", content)
        assert_match("circleci/node@2", content)
      end

      assert_file "config/database.yml.ci" do |content|
        assert_match("boring_generators_test", content)
      end
    end
  end
end
