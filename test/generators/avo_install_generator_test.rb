# frozen_string-literal: true

require 'test_helper'
require 'generators/boring/avo/install/install_generator'

class AvoInstallGeneratorTest < Rails::Generators::TestCase
  tests Boring::Avo::InstallGenerator
  setup :build_app
  teardown :teardown_app

  include GeneratorHelper

  def destination_root
    app_path
  end

  def test_should_configure_avo_gem
    Dir.chdir(app_path) do
      quietly { run_generator }

      assert_gem 'avo'

      assert_file 'config/initializers/avo.rb' do |content|
        assert_match(/Avo.configure do |config|/, content)
        assert_match(/config.root_path = '\/avo'/, content)
      end

      assert_file 'config/routes.rb' do |content|
        assert_match(/mount Avo::Engine, at: Avo.configuration.root_path/, content)
      end
    end
  end
end
