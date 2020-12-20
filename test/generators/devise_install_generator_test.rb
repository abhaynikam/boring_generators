# frozen_string_literal: true

require "test_helper"
require "generators/boring/devise/install/install_generator"

class DeviseInstallGeneratorTest < Rails::Generators::TestCase
  tests Boring::Devise::InstallGenerator
  setup :build_app
  teardown :teardown_app

  include GeneratorHelper

  def destination_root
    app_path
  end

  def test_should_install_devise_successfully
    Dir.chdir(app_path) do
      quietly { run_generator }

      assert_file "Gemfile" do |content|
        assert_match(/devise/, content)
      end

      assert_file "config/environments/development.rb" do |content|
        assert_match(/config.action_mailer.default_url_options/, content)
      end
    end
  end
end
