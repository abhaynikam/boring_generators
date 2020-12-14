# frozen_string_literal: true

require "test_helper"
require "generators/boring/simple_form/install/install_generator"

class SimpleFormInstallGeneratorTest < Rails::Generators::TestCase
  tests Boring::SimpleForm::InstallGenerator
  setup :build_app
  teardown :teardown_app

  include GeneratorHelper

  def destination_root
    app_path
  end

  def test_should_install_simple_form_successfully
    Dir.chdir(app_path) do
      quietly { run_generator }

      assert_file "Gemfile" do |content|
        assert_match(/simple_form/, content)
      end

      assert_file "config/initializers/simple_form.rb"
      assert_file "config/locales/simple_form.en.yml"
      assert_file "lib/templates/erb/scaffold/_form.html.erb"
    end
  end

  def test_should_skip_running_simple_form_generator
    Dir.chdir(app_path) do
      quietly { run_generator [destination_root, "--skip_generator"] }

      assert_file "Gemfile" do |content|
        assert_match(/simple_form/, content)
      end

      assert_no_file "config/initializers/simple_form.rb"
    end
  end

  def test_should_run_simple_form_generator_with_css_framework
    Dir.chdir(app_path) do
      quietly { run_generator [destination_root, "--css_framework=bootstrap"] }

      assert_file "config/initializers/simple_form_bootstrap.rb"
    end
  end

  def test_should_raise_error_for_invalid_css_framework_option
    original_stdout = $stdout
    $stdout = StringIO.new

    Dir.chdir(app_path) do
      quietly { run_generator [destination_root, "--css_framework=invalid_option"] }

      expected = "ERROR: Invalid option css_framework: invalid_option. Generator allows css_framework: bootstrap, foundation"
      $stdout.rewind
      assert_match expected, $stdout.read
    end
  ensure
    $stdout = original_stdout
  end
end
