# frozen_string_literal: true

require "test_helper"
require "generators/boring/rswag/install/install_generator"

class RswagInstallGeneratorTest < Rails::Generators::TestCase
  tests Boring::Rswag::InstallGenerator
  setup :build_app
  teardown :teardown_app

  include GeneratorHelper
  include ActiveSupport::Testing::Isolation

  def destination_root
    app_path
  end

  def test_should_install_rswag
    Dir.chdir(app_path) do
      quietly { generator.add_rswag_gem }

      assert_gem "rswag"
    end
  end

  def test_should_configure_rswag
    Dir.chdir(app_path) do
      install_rspec

      quietly { run_generator }

      assert_gem "rswag"
      assert_file "spec/swagger_helper.rb"
      assert_file "config/initializers/rswag_api.rb"
      assert_file "config/initializers/rswag_ui.rb"

      assert_file "config/routes.rb" do |content|
        assert_match(/mount Rswag::Ui::Engine => '\/api-docs'/, content)
        assert_match(/mount Rswag::Api::Engine => '\/api-docs'/, content)
      end

      assert_file "spec/swagger_helper.rb" do |content|
        assert_match(/url: 'http:\/\/{defaultHost}'/, content)
        assert_match(/default: 'localhost:3000'/, content)
      end
    end
  end

  def test_should_add_correct_rails_port
    Dir.chdir(app_path) do
      install_rspec

      quietly { run_generator [destination_root, "--rails_port=3001"] }

      assert_file "spec/swagger_helper.rb" do |content|
        assert_match(/default: 'localhost:3001'/, content)
      end
    end
  end

  def test_should_exit_if_rspec_is_not_installed
    assert_raises SystemExit do
      quietly { generator.verify_presence_of_rspec_gem }
    end
  end

  private

  def install_rspec
    Bundler.with_unbundled_env do
      `bundle add rspec-rails --group development,test`
    end
  end
end
