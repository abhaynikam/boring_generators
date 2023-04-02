# frozen_string_literal: true

require "test_helper"
require "generators/boring/rubocop/install/install_generator"

class RubocopInstallGeneratorTest < Rails::Generators::TestCase
  tests Boring::Rubocop::InstallGenerator
  setup :build_app
  teardown :teardown_app

  include GeneratorHelper
  include ActiveSupport::Testing::Isolation

  def destination_root
    app_path
  end

  class BaseConfigurationsTest < self
    def test_should_install_rubocop_successfully
      Dir.chdir(app_path) do
        quietly { run_generator }

        assert_file "Gemfile" do |content|
          assert_match(/rubocop/, content)
          assert_match(/rubocop-rails/, content)
          assert_match(/rubocop-performance/, content)
          assert_match(/rubocop-rake/, content)
        end

        assert_file ".rubocop.yml" do |content|
          assert_match("2.7.1", content)
          assert_match("AllCops", content)
        end
      end
    end

    def test_should_skip_adding_rubocop_rules
      Dir.chdir(app_path) do
        quietly { run_generator [destination_root, "--skip_adding_rubocop_rules"] }

        assert_file ".rubocop.yml" do |content|
          assert_no_match("AllCops", content)
          assert_no_match("2.7.1", content)
        end
      end
    end

    def test_should_add_target_ruby_version
      Dir.chdir(app_path) do
        quietly { run_generator [destination_root, "--ruby_version=2.6.3"] }

        assert_file ".rubocop.yml" do |content|
          assert_match("AllCops", content)
          assert_match("2.6.3", content)
        end
      end
    end
  end

  class TestFrameworkGemTest < self
    def test_should_skip_gem_extension
      quietly { generator.add_rubocop_gems }

      assert_file "Gemfile" do |content|
        assert_no_match(/rubocop-rspec/, content)
        assert_no_match(/rubocop-minitest/, content)
      end
    end

    def test_should_raise_error_for_invalid_option
      assert_raises(NotImplementedError) do
        run_generator ["--test_gem=invalid_test_extension_gem"]
      end
    end

    def test_should_configure_correct_gem_extension
      quietly { run_generator ["--test_gem=minitest"] }

      assert_file "Gemfile" do |content|
        assert_match(/rubocop/, content)
        assert_match(/rubocop-rails/, content)
        assert_match(/rubocop-performance/, content)
        assert_match(/rubocop-rake/, content)
        assert_match(/rubocop-minitest/, content)
      end

      assert_file ".rubocop.yml" do |content|
        assert_match("rubocop-minitest", content)
      end
    end
  end
end
