# frozen_string_literal: true

require "test_helper"
require "generators/boring/font_awesome/ruby_gem/install/install_generator"

class FontAwesomeRubyGemInstallGeneratorTest < Rails::Generators::TestCase
  tests Boring::FontAwesome::RubyGem::InstallGenerator
  setup :build_app
  teardown :teardown_app

  include GeneratorHelper

  def destination_root
    app_path
  end

  def test_should_install_font_awesome_via_rubygems_successfully
    Dir.chdir(app_path) do
      FileUtils.touch("#{app_path}/app/assets/stylesheets/application.scss")

      quietly { run_generator }

      assert_file "Gemfile" do |content|
        assert_match(/font-awesome-sass/, content)
      end

      assert_file "app/assets/stylesheets/application.scss" do |content|
        assert_match(/font-awesome-sprockets/, content)
        assert_match(/font-awesome/, content)
      end
    end
  end

  def test_should_warning_about_missing_application_scss
    original_stdout = $stdout
    $stdout = StringIO.new

    Dir.chdir(app_path) do
      FileUtils.rm_rf("#{app_path}/app/assets/stylesheets/application.scss")

      expected = "Looks like the application.css.scss is missing. Please rename the file and re-run the generator."
      generator.import_font_awesome_stylesheet
      $stdout.rewind
      assert_match expected, $stdout.read
    end
  ensure
    $stdout = original_stdout
  end
end
