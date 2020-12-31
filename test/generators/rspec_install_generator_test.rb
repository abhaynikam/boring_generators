# frozen_string_literal: true

require "test_helper"
require "generators/boring/rspec/install/install_generator"

class RspecInstallGeneratorTest < Rails::Generators::TestCase
  tests Boring::Rspec::InstallGenerator
  setup :build_app
  teardown :teardown_app

  include GeneratorHelper

  def destination_root
    app_path
  end

  def test_should_install_rspec_successfully
    Dir.chdir(app_path) do
      quietly { run_generator }

      assert_file "Gemfile" do |content|
        assert_match(/:development, :test/, content)
        assert_match(/rspec-rails/, content)
      end
    end
  end

  def test_should_install_rspec_with_version
    Dir.chdir(app_path) do
      quietly { run_generator ["--version=4.0.1"] }

      assert_file "Gemfile" do |content|
        assert_match(/:development, :test/, content)
        assert_match(/rspec-rails/, content)
        assert_match(/~> 4.0.1/, content)
      end
    end
  end
end
