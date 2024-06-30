# frozen_string_literal: true

require "test_helper"
require "generators/boring/cancancan/install/install_generator"

class CanCanCanInstallGeneratorTest < Rails::Generators::TestCase
  tests Boring::Cancancan::InstallGenerator
  setup :build_app
  teardown :teardown_app

  include GeneratorHelper
  include ActiveSupport::Testing::Isolation

  def destination_root
    app_path
  end

  def test_should_configure_cancancan
    Dir.chdir(app_path) do
      quietly { run_generator }

      assert_gem "cancancan"
      assert_file "app/models/ability.rb"
    end
  end

  def test_should_skip_cancancan_configuration
    Dir.chdir(app_path) do
      quietly { run_generator %w[--skip-config] }

      assert_no_file "app/models/ability.rb"
    end
  end
end
