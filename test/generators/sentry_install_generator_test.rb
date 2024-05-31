# frozen_string_literal: true

require 'test_helper'
require 'generators/boring/sentry/install/install_generator'

class SentryInstallGeneratorTest < Rails::Generators::TestCase
  tests Boring::Sentry::InstallGenerator
  setup :build_app
  teardown :teardown_app

  include GeneratorHelper
  include ActiveSupport::Testing::Isolation

  def destination_root
    app_path
  end

  def test_should_configure_sentry_gem
    Dir.chdir(app_path) do
      quietly { run_generator }

      assert_gem 'sentry-ruby'
      assert_gem 'sentry-rails'

      assert_file 'config/initializers/sentry.rb' do |content|
        assert_match(/config.dsn = Rails.application.credentials.dig\(:sentry, :dsn_key\)/, content)
        assert_match(/config.breadcrumbs_logger = \[:active_support_logger, :http_logger\]\n/, content)
      end
    end
  end

  def test_should_configure_dsn_key_as_env_variable
    Dir.chdir(app_path) do
      quietly { run_generator  [destination_root, '--use_env_variable'] }

      assert_gem 'sentry-ruby'
      assert_gem 'sentry-rails'

      assert_file 'config/initializers/sentry.rb' do |content|
        assert_match(/config.dsn = ENV\['SENTRY_DSN_KEY'\]\n/, content)
      end
    end
  end

  def test_should_configure_custom_breadcrumbs_logger
    Dir.chdir(app_path) do
      quietly { run_generator [destination_root, "--breadcrumbs_logger=http_logger"]}

      assert_gem 'sentry-ruby'
      assert_gem 'sentry-rails'

      assert_file 'config/initializers/sentry.rb' do |content|
        assert_match(/config.breadcrumbs_logger = \[:http_logger\]\n/, content)
      end
    end
  end
end
