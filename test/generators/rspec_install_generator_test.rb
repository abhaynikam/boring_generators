# frozen_string_literal: true

require "test_helper"
require "generators/boring/rspec/install/install_generator"

class RspecInstallGeneratorTest < Rails::Generators::TestCase
  tests Boring::Rspec::InstallGenerator
  setup :build_app
  teardown :teardown_app

  include GeneratorHelper
  include ActiveSupport::Testing::Isolation

  def destination_root
    app_path
  end

  def test_should_install_rspec_successfully
    Dir.chdir(app_path) do
      quietly { run_generator }

      assert_gem "faker"
      assert_gem "rspec-rails"
      assert_gem "factory_bot_rails"
      assert_file "config/application.rb" do |content|
        assert_match(/g.test_framework :rspec/, content)
      end
    end
  end

  def test_should_skip_adding_factory_bot
    Dir.chdir(app_path) do
      quietly { run_generator [destination_root, "--skip_factory_bot"] }

      assert_gem "faker"
      assert_gem "rspec-rails"
    end
  end

  def test_should_skip_adding_faker
    Dir.chdir(app_path) do
      quietly { run_generator [destination_root, "--skip_faker"] }

      assert_gem "rspec-rails"
      assert_gem "factory_bot_rails"
      assert_gem "factory_bot_rails"
    end
  end
end
