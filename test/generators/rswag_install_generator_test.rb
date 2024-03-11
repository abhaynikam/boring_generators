# frozen_string_literal: true

require "test_helper"
require "generators/boring/rswag/install/install_generator"

class RswagInstallGeneratorTest < Rails::Generators::TestCase
  tests Boring::Rswag::InstallGenerator
  setup :build_app
  teardown :teardown_app

  include GeneratorHelper
  include ActiveSupport::Testing::Isolation

  def destination_root
    app_path
  end

  def test_should_exit_if_rspec_is_not_installed
    assert_raises SystemExit do
      quietly { generator.verify_presence_of_rspec_gem }
    end
  end

  def test_should_configure_rswag
    Dir.chdir(app_path) do
      install_rspec

      quietly { run_generator }

      assert_gem "rswag-api"
      assert_gem "rswag-ui"
      assert_gem "rswag-specs"
      assert_file "spec/swagger_helper.rb"
      assert_file "config/initializers/rswag_api.rb"
      assert_file "config/initializers/rswag_ui.rb"

      assert_file "config/routes.rb" do |content|
        assert_match(/mount Rswag::Ui::Engine => '\/api-docs'/, content)
        assert_match(/mount Rswag::Api::Engine => '\/api-docs'/, content)
      end

      assert_file "spec/swagger_helper.rb" do |content|
        assert_match(/url: 'http:\/\/{defaultHost}'/, content)
        assert_match(/default: 'localhost:3000'/, content)
        assert_match(/scheme: :basic/, content)
      end
    end
  end

  def test_should_add_correct_rails_port
    Dir.chdir(app_path) do
      install_rspec

      quietly { run_generator [destination_root, "--rails_port=3001"] }

      assert_file "spec/swagger_helper.rb" do |content|
        assert_match(/default: 'localhost:3001'/, content)
      end
    end
  end

  def test_should_skip_api_authentication
    Dir.chdir(app_path) do
      install_rspec

      quietly { run_generator [destination_root, "--skip_api_authentication=true"] }

      assert_file "spec/swagger_helper.rb" do |content|
        refute_match(/securitySchemes/, content)
      end
    end
  end

  def test_should_add_bearer_authentication
    Dir.chdir(app_path) do
      install_rspec

      quietly { run_generator [destination_root, "--authentication_type=bearer"] }

      assert_file "spec/swagger_helper.rb" do |content|
        assert_match(/scheme: :bearer/, content)
      end
    end
  end

  def test_should_add_api_key_authentication
    Dir.chdir(app_path) do
      install_rspec

      quietly { run_generator [destination_root, "--authentication_type=api_key", '--api_authentication_options={ "name": "api_key", "in": "query" }'] }

      assert_file "spec/swagger_helper.rb" do |content|
        assert_match(/type: :apiKey/, content)
        assert_match(/name: "api_key"/, content)
        assert_match(/in: "query"/, content)
      end
    end
  end

  def test_should_configure_ui_authentication
    Dir.chdir(app_path) do
      install_rspec

      quietly { run_generator [destination_root, "--enable_swagger_ui_authentication=true"] }

      assert_file "config/initializers/rswag_ui.rb" do |content|
        refute_match(/# c.basic_auth_enabled/, content)
        assert_match(/c.basic_auth_enabled = true/, content)
        refute_match(/# c.basic_auth_credentials/, content)
        assert_includes(content, 'c.basic_auth_credentials ENV.fetch("SWAGGER_UI_LOGIN_USERNAME", "admin"), Rails.application.credentials.dig(:swagger_ui, :password)')
      end
    end
  end

  def test_should_exit_if_api_key_authentication_options_is_empty
    Dir.chdir(app_path) do
      install_rspec

      assert_raises SystemExit do
        quietly { run_generator [destination_root, "--authentication_type=api_key", '--api_authentication_options={ "name": "api_key" }'] }
      end
    end
  end

  def test_should_exit_if_api_key_authentication_options_dont_match
    Dir.chdir(app_path) do
      install_rspec

      assert_raises SystemExit do
        quietly { run_generator [destination_root, "--authentication_type=api_key", '--api_authentication_options={ "name": "api_key" }'] }
      end
    end
  end

  private

  def install_rspec
    Bundler.with_unbundled_env do
      `bundle add rspec-rails --group development,test`
    end
  end
end
