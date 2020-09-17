# frozen_string_literal: true

require "test_helper"
require "generators/boring/pry/install/install_generator"

class PryInstallGeneratorTest < Rails::Generators::TestCase
  tests Boring::Pry::InstallGenerator
  setup :build_app
  teardown :teardown_app

  include GeneratorHelper

  def destination_root
    app_path
  end

  def test_should_install_pry_successfully
    Dir.chdir(app_path) do
      quietly { run_generator }

      assert_file "Gemfile" do |content|
        assert_match(/pry/, content)
        assert_match(/pry-rails/, content)
      end

      assert_file ".pryrc"
    end
  end

  def test_should_skip_adding_pryrc_configuration
    Dir.chdir(app_path) do
      quietly { run_generator [destination_root, "--skip_configuration"] }

      assert_no_file "pryrc"
    end
  end
end
