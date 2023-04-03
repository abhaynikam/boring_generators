# frozen_string_literal: true

require "test_helper"
require "generators/boring/letter_opener/install/install_generator"

class AuditInstallGeneratorTest < Rails::Generators::TestCase
  tests Boring::LetterOpener::InstallGenerator
  setup :build_app
  teardown :teardown_app

  include GeneratorHelper

  def destination_root
    app_path
  end

  def test_should_install_letter_opener_gem
    Dir.chdir(app_path) do
      quietly { generator.add_letter_opener_gem }

      assert_file "Gemfile" do |content|
        assert_match(/letter_opener/, content)
      end
    end
  end

  def test_should_add_gem_configurations
    Dir.chdir(app_path) do
      quietly { generator.configure_letter_opener }

      assert_file "config/environments/development.rb" do |content|
        assert_match(/config.action_mailer.delivery_method = :letter_opener/, content)
        assert_match(/config.action_mailer.perform_deliveries = true/, content)
      end
    end
  end
end
