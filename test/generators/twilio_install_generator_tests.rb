# frozen_string_literal: true

require "test_helper"
require "generators/boring/twilio/install/install_generator"

class TwilioInstallGeneratorTest < Rails::Generators::TestCase
  tests Boring::Twilio::InstallGenerator
  setup :build_app
  teardown :teardown_app

  include GeneratorHelper
  include ActiveSupport::Testing::Isolation

  def destination_root
    app_path
  end

  def test_should_install_twilio_successfully
    Dir.chdir(app_path) do
      quietly { run_generator }

      assert_file "Gemfile" do |content|
        assert_match(/twilio-ruby/, content)
      end

      assert_file "config/initializers/twilio.rb"
    end
  end
end
