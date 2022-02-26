# frozen_string_literal: true

require "test_helper"
require "generators/boring/flipper/install/install_generator"

class FlipperInstallGeneratorTest < Rails::Generators::TestCase
  tests Boring::Flipper::InstallGenerator
  setup :build_app
  teardown :teardown_app

  include GeneratorHelper

  def destination_root
    app_path
  end

  def test_should_install_flipper_successfully
    Dir.chdir(app_path) do
      quietly { run_generator }

      assert_gem "flipper-ui"
      assert_gem "flipper-active_record"
      assert_file "config/initializers/flipper.rb"
    end
  end
end
