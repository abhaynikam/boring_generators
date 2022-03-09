# frozen_string_literal: true

require "test_helper"
require "generators/boring/faker/install/install_generator"

class FakerInstallGeneratorTest < Rails::Generators::TestCase
  tests Boring::Faker::InstallGenerator
  setup :build_app
  teardown :teardown_app

  include GeneratorHelper
  include ActiveSupport::Testing::Isolation

  def destination_root
    app_path
  end

  def test_should_install_faker_successfully
    Dir.chdir(app_path) do
      quietly { run_generator }

      assert_gem "faker"
    end
  end
end
