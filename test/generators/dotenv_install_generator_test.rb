# frozen_string_literal: true

require 'test_helper'
require 'generators/boring/dotenv/install/install_generator'

class DotenvInstallGeneratorTest < Rails::Generators::TestCase
  tests Boring::Dotenv::InstallGenerator
  setup :build_app
  teardown :teardown_app

  include GeneratorHelper

  def destination_root
    app_path
  end

  def test_should_install_dotenv_gem
    Dir.chdir(app_path) do
      quietly { run_generator }

      assert_gem 'dotenv-rails'

      assert_file '.env' do |content|
        assert_match(/# Add your environment variables here/, content)
        assert_match(/# SECRET_KEY_BASE=your_secret_key/, content)
      end

      assert_file '.env.sample'

      assert_file '.gitignore' do |content|
        assert_match(/\/.env*/, content)
        assert_match(/!\/.env.*/, content)
      end
    end
  end
end
