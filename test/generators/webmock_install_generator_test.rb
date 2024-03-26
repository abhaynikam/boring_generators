# frozen_string_literal: true

require "test_helper"
require "generators/boring/webmock/install/install_generator"

class WebmockInstallGeneratorTest < Rails::Generators::TestCase
  tests Boring::Webmock::InstallGenerator
  setup :build_app
  teardown :teardown_app

  include GeneratorHelper
  include ActiveSupport::Testing::Isolation

  def destination_root
    app_path
  end

  def test_should_configure_webmock
    Dir.chdir(app_path) do
      quietly { run_generator }

      assert_file "Gemfile" do |content|
        assert_match(/webmock/, content)
      end

      assert_file "test/test_helper.rb" do |content|
        assert_match("\nrequire 'webmock/minitest'\nWebMock.disable_net_connect!(allow_localhost: true)\n", content)
      end
    end
  end

  def test_should_exit_if_invalid_test_framework_is_passed
    assert_raises(SystemExit) do
      quietly { run_generator [destination_root, "--app_test_framework=invalid_test_framework"] }
    end
  end

  def test_should_exit_if_minitest_is_not_configured
    `mv test invalid_test`

    assert_raises(SystemExit) do
      quietly { run_generator [destination_root, "--app_test_framework=minitest"] }
    end

    # rename back to valid test folder so other tests are not affected
    `mv invalid_test test`
  end

  def test_should_exit_if_rspec_is_not_configured
    Dir.chdir(app_path) do
      assert_raises(SystemExit) do
        quietly do 
          Bundler.with_unbundled_env do
            # add gem but not specs folder
            `bundle add rspec-rails --group development,test`
          end

          run_generator [destination_root, "--app_test_framework=rspec"]
        end
      end
    end
  end

  def test_should_configure_webmock_for_rspec
    Dir.chdir(destination_root) do
      install_rspec

      quietly do
        run_generator [destination_root, "--app_test_framework=rspec"]
       end

      assert_file "spec/spec_helper.rb" do |content|
        assert_match(/require ['"]webmock\/rspec['"]/, content)
        assert_includes(content, "WebMock.disable_net_connect!(allow_localhost: true)")
      end
    end
  end

  private

  def install_rspec
    Bundler.with_unbundled_env do
      `bundle add rspec-rails --group development,test`
      `bundle exec rails generate rspec:install`
    end
  end
end
