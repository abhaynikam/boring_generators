# frozen_string_literal: true

require 'test_helper'
require 'generators/boring/figjam/install/install_generator'

class FigjamInstallGeneratorTest < Rails::Generators::TestCase
  tests Boring::Figjam::InstallGenerator
  setup :build_app
  teardown :teardown_app

  include GeneratorHelper

  def destination_root
    app_path
  end

  def test_should_configure_figjam
    Dir.chdir(app_path) do
      quietly { run_generator }

      assert_gem 'figjam'

      assert_file 'config/application.yml' do |content|
        assert_match(/# Add configuration values here, as shown below/, content)
        assert_match(/# GOOGLE_TAG_MANAGER_ID: GTM-12345/, content)
      end

      assert_file 'config/application.yml.sample'

      assert_file '.gitignore' do |content|
        assert_match(/config\/application.yml/, content)
      end
    end
  end
end
