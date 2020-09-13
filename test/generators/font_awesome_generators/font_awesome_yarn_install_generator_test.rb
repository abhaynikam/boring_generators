# frozen_string_literal: true

require "test_helper"
require "generators/boring/font_awesome/yarn/install/install_generator"

class FontAwesomeYarnInstallGeneratorTest < Rails::Generators::TestCase
  tests Boring::FontAwesome::Yarn::InstallGenerator
  setup :build_app
  teardown :teardown_app

  include GeneratorHelper

  def destination_root
    app_path
  end

  def test_should_install_font_awesome_via_yarn_successfully
    Dir.chdir(app_path) do
      quietly { run_generator }

      assert_file "package.json" do |content|
        assert_match(/@fortawesome\/fontawesome-free/, content)
      end

      assert_file "app/javascript/stylesheets/application.scss" do |content|
        assert_match(/@fortawesome\/fontawesome-free/, content)
      end

      assert_file "app/javascript/packs/application.js" do |content|
        assert_match(/@fortawesome\/fontawesome-free\/js\/all/, content)
      end
    end
  end

  def test_should_warning_about_missing_application_scss
    original_stdout = $stdout
    $stdout = StringIO.new

    Dir.chdir(app_path) do
      FileUtils.rm_rf("#{app_path}/app/javascript/packs/application.js")

      expected = "ERROR: Looks like the webpacker installation is incomplete. Could not find application.js in app/javascript/packs."
      generator.import_font_awesome_javascript
      $stdout.rewind
      assert_match expected, $stdout.read
    end
  ensure
    $stdout = original_stdout
  end
end
