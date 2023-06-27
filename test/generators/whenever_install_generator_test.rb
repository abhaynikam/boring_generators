# frozen_string_literal: true

require "test_helper"
require "generators/boring/whenever/install/install_generator"

class WheneverInstallGeneratorTest < Rails::Generators::TestCase
  tests Boring::Whenever::InstallGenerator
  setup :build_app
  teardown :teardown_app

  include GeneratorHelper
  include ActiveSupport::Testing::Isolation

  def destination_root
    app_path
  end

  def test_should_install_whenever_gem
    Dir.chdir(app_path) do
      quietly { generator.add_whenever_gem }

      assert_gem "whenever"
    end
  end

  def test_should_configure_whenever
    Dir.chdir(app_path) do
      quietly { run_generator }

      assert_file "config/schedule.rb"
    end
  end
end
