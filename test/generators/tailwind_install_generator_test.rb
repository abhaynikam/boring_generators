# frozen_string_literal: true

require "test_helper"
require "generators/boring/tailwind/install/install_generator"

class TailwindInstallGeneratorTest < Rails::Generators::TestCase
  tests Boring::Tailwind::InstallGenerator
  setup :build_app
  teardown :teardown_app

  include GeneratorHelper

  def destination_root
    app_path
  end

  def test_should_install_tailwind_successfully
    Dir.chdir(app_path) do
      quietly { run_generator }

      assert_file "package.json" do |content|
        assert_match(/@tailwindcss\/ui/, content)
        assert_match(/tailwindcss/, content)
      end

      assert_file "tailwind.config.js" do |content|
        assert_match(/colors:/, content)
        assert_match(/screens:/, content)
        assert_match(/spacing:/, content)
        assert_match(/animation:/, content)
        assert_match(/backgroundColor:/, content)
        assert_match(/backgroundImage:/, content)
        assert_match(/fontSize:/, content)
      end

      assert_file "postcss.config.js" do |content|
        assert_match(/require\('tailwindcss'\)/, content)
      end

      assert_file "app/javascript/stylesheets/application.scss" do |content|
        assert_match(/tailwindcss\/base/, content)
        assert_match(/tailwindcss\/components/, content)
        assert_match(/tailwindcss\/utilities/, content)
      end

      assert_file "app/javascript/packs/application.js" do |content|
        assert_match(/stylesheets\/application/, content)
      end

      assert_file "app/views/layouts/application.html.erb" do |content|
        assert_match(/stylesheet_pack_tag \'application\'/, content)
      end
    end
  end

  def test_should_skip_adding_tailwindcss_ui_library_when_used_option_skip_tailwind_css_ui
    Dir.chdir(app_path) do
      quietly { run_generator [destination_root, "--skip_tailwind_css_ui"] }

      assert_file "package.json" do |content|
        assert_no_match(/@tailwindcss\/ui/, content)
        assert_match(/tailwindcss/, content)
      end
    end
  end

  def test_should_skip_adding_full_tailwind_config_when_user_option_skip_tailwind_init_full
    Dir.chdir(app_path) do
      quietly { run_generator [destination_root, "--skip_tailwind_init_full"] }

      assert_file "package.json" do |content|
        assert_match(/tailwindcss/, content)
      end

      assert_file "tailwind.config.js" do |content|
        expected = "module.exports = {\n  purge: [],\n  darkMode: false, // or 'media' or 'class'\n  theme: {\n    extend: {},\n  },\n  variants: {\n    extend: {},\n  },\n  plugins: [],\n}\n"
        assert_match(expected, content)
      end
    end
  end

  def test_should_append_tailwind_imports_to_the_application_scss_file
    Dir.chdir(app_path) do
      FileUtils.mkdir("#{app_path}/app/javascript/stylesheets")
      FileUtils.touch("#{app_path}/app/javascript/stylesheets/application.scss")

      quietly { run_generator }

      assert_file "app/javascript/stylesheets/application.scss" do |content|
        assert_match(/tailwindcss\/base/, content)
        assert_match(/tailwindcss\/components/, content)
        assert_match(/tailwindcss\/utilities/, content)
      end
    end
  end

  def test_should_warning_about_missing_application_js
    original_stdout = $stdout
    $stdout = StringIO.new

    Dir.chdir(app_path) do
      FileUtils.rm_rf("#{app_path}/app/javascript/packs/application.js")

      expected = "ERROR: Looks like the webpacker installation is incomplete. Could not find application.js in app/javascript/packs."
      generator.insert_stylesheet_in_the_application
      $stdout.rewind
      assert_match expected, $stdout.read
    end
  ensure
    $stdout = original_stdout
  end
end
