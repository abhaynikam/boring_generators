# frozen_string_literal: true

require "test_helper"
require "generators/boring/pundit/install/install_generator"

class PunditInstallGeneratorTest < Rails::Generators::TestCase
  tests Boring::Pundit::InstallGenerator
  setup :build_app
  teardown :teardown_app

  include GeneratorHelper

  def destination_root
    app_path
  end

  def test_should_install_pundit_successfully
    Dir.chdir(app_path) do
      quietly { run_generator }

      assert_file "Gemfile" do |content|
        assert_match(/pundit/, content)
      end

      assert_file "app/controllers/application_controller.rb" do |content|
        assert_match(/include Pundit/, content)
        assert_match(/:verify_authorized/, content)
        assert_match(/rescue_from/, content)
      end
    end
  end

  def test_should_skip_adding_ensuring_policies
    Dir.chdir(app_path) do
      quietly { run_generator [destination_root, "--skip_ensuring_policies"] }

      assert_file "app/controllers/application_controller.rb" do |content|
        assert_no_match(/verify_authorized/, content)
      end
    end
  end

  def test_should_skip_adding_rescue
    Dir.chdir(app_path) do
      quietly { run_generator [destination_root, "--skip_rescue"] }

      assert_file "app/controllers/application_controller.rb" do |content|
        assert_no_match(/rescue_from/, content)
        assert_no_match(/user_not_authorized/, content)
      end
    end
  end

  def test_should_skip_runnig_pundit_generator
    Dir.chdir(app_path) do
      quietly { run_generator [destination_root, "--skip_generator"] }

      assert_no_file "app/policies/application_policy.rb"
    end
  end
end
