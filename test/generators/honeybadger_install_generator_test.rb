# fronzen_string_literal: true

require 'test_helper'
require 'generators/boring/honeybadger/install/install_generator'

class HoneybadgerInstallGeneratorTest < Rails::Generators::TestCase
  tests Boring::Honeybadger::InstallGenerator
  setup :build_app
  teardown :teardown_app

  include GeneratorHelper

  def destination_root
    app_path
  end

  def test_should_configure_honeybadger
    Dir.chdir(app_path) do
      quietly { run_generator }

      assert_gem 'honeybadger'

      assert_file 'config/honeybadger.yml' do |content|
        assert_match(/\napi_key: Rails.application.credentials.dig\(:honeybadger, :api_key\)\n/, content)
      end
    end
  end

  def test_should_use_env_variable_for_api_key
    Dir.chdir(app_path) do
      quietly { run_generator([destination_root, '--use_env_variable']) }

      assert_gem 'honeybadger'

      assert_file 'config/honeybadger.yml' do |content|
        assert_match(/api_key: ENV\['HONEYBADGER_API_KEY'\]\n/, content)
      end
    end
  end
end