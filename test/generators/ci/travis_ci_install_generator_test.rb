# frozen_string_literal: true

require "test_helper"
require "generators/boring/ci/travisci/install/install_generator"

class TravisciInstallGeneratorTest < Rails::Generators::TestCase
  tests Boring::Ci::Travisci::InstallGenerator
  setup :build_app
  teardown :teardown_app

  include GeneratorHelper

  def destination_root
    app_path
  end

  def test_generator_should_install_travis_ci_successfully
    Dir.chdir(app_path) do
      quietly { run_generator }

      assert_file ".travis.yml" do |content|
        assert_match("2.7.1", content)
      end
    end
  end

  def test_generator_should_use_ruby_version_passed_in_params
    Dir.chdir(app_path) do
      quietly { run_generator [destination_root, "--ruby_version=2.6.3"] }

      assert_file ".travis.yml" do |content|
        assert_match("2.6.3", content)
      end
    end
  end
end
