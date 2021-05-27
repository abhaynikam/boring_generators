# frozen_string_literal: true

require "test_helper"
require "generators/boring/stimulus/install/install_generator"

class TwilioInstallGeneratorTest < Rails::Generators::TestCase
  tests Boring::Stimulus::InstallGenerator
  setup :build_app
  teardown :teardown_app

  include GeneratorHelper
  include ActiveSupport::Testing::Isolation

  def destination_root
    app_path
  end

  def test_should_install_stimulus_successfully
    Dir.chdir(app_path) do
      quietly { run_generator }

      assert_gem "stimulus-rails"
      assert_file "app/javascript/controllers/hello_controller.js"
      assert_file "app/javascript/packs/application.js" do |content|
        assert_match('import "controllers"', content)
      end
    end
  end
end
