# frozen_string_literal: true

require "test_helper"
require "generators/boring/factory_bot/install/install_generator"

class FactoryBotInstallGeneratorTest < Rails::Generators::TestCase
  tests Boring::FactoryBot::InstallGenerator
  setup :build_app
  teardown :teardown_app

  include GeneratorHelper
  include ActiveSupport::Testing::Isolation

  def destination_root
    app_path
  end

  def test_should_install_factory_bot_successfully
    Dir.chdir(app_path) do
      quietly { run_generator }

      assert_gem "factory_bot_rails"
      assert_file "test/factories/users.rb"
      assert_file "test/test_helper.rb" do |content|
        assert_match(/include FactoryBot::Syntax::Methods/, content)
      end
    end
  end

  def test_should_skip_adding_factory_bot_sample
    Dir.chdir(app_path) do
      quietly { run_generator [destination_root, "--skip_factory"] }

      assert_no_file "test/factories/users.rb"
    end
  end
end
