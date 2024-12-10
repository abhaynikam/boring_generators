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

  def test_should_configure_tailwind_gem
    Dir.chdir(app_path) do
      quietly { run_generator }

      assert_gem "tailwindcss-rails"
      assert_file "app/assets/stylesheets/application.tailwind.css"
      assert_file "config/tailwind.config.js"

      assert_file "Procfile.dev" do |content|
        assert_match(/css: bin\/rails tailwindcss:watch/, content)
      end

      assert_file "app/views/layouts/application.html.erb" do |content|
        assert_match(/stylesheet_link_tag \"tailwind\"/, content)
      end
    end
  end
end
