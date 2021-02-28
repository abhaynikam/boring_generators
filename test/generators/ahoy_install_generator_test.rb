# frozen_string_literal: true

require "test_helper"
require "generators/boring/ahoy/install/install_generator"

class AhoyInstallGeneratorTest < Rails::Generators::TestCase
  tests Boring::Ahoy::InstallGenerator
  setup :build_app
  teardown :teardown_app

  include GeneratorHelper
  include ActiveSupport::Testing::Isolation

  def destination_root
    app_path
  end

  def test_should_install_ahoy_gem_successfully
    Dir.chdir(app_path) do
      quietly { run_generator }

      assert_gem "ahoy_matey"
      assert_file "config/initializers/ahoy.rb"
      assert_migration "db/migrate/create_ahoy_visits_and_events.rb"
    end
  end
end
