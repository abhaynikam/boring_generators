# frozen_string_literal: true

require "test_helper"
require "boring/generators/tailwind/install/install_generator"

class TailwindInstallGeneratorTest < Rails::Generators::TestCase
  tests Boring::Generators::Tailwind::Install::InstallGenerator
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
        assert_match(/important:/, content)
        assert_match(/prefix:/, content)
        assert_match(/target:/, content)
        assert_match(/purge:/, content)
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
        expected = "module.exports = {\n  purge: [],\n  theme: {\n    extend: {},\n  },\n  variants: {},\n  plugins: [],\n}\n"
        assert_match(expected, content)
      end
    end
  end

  def test_should_warning_about_missing_application_js
    Dir.chdir(app_path) do
      FileUtils.rm_rf("app/javascript/packs/application.js")

      assert_raises do
        quietly { run_generator }
      end
    end
  end
end
