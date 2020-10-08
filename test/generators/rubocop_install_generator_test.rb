# frozen_string_literal: true

require "test_helper"
require "generators/boring/rubocop/install/install_generator"

class RubocopInstallGeneratorTest < Rails::Generators::TestCase
  tests Boring::Rubocop::InstallGenerator
  setup :build_app
  teardown :teardown_app

  include GeneratorHelper

  def destination_root
    app_path
  end

  def test_should_install_rubocop_successfully
    Dir.chdir(app_path) do
      quietly { run_generator }

      assert_file "Gemfile" do |content|
        assert_match(/rubocop/, content)
        assert_match(/rubocop-rails/, content)
        assert_match(/rubocop-performance/, content)
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

      assert_file "Gemfile" do |content|
        assert_match(/rubocop/, content)
        assert_match(/rubocop-rails/, content)
        assert_match(/rubocop-performance/, content)
      end

      assert_file ".rubocop.yml" do |content|
        assert_no_match("2.7.1", content)
        assert_no_match("AllCops", content)
      end
    end
  end

  def test_should_add_target_ruby_version
    Dir.chdir(app_path) do
      quietly { run_generator [destination_root, "--ruby_version=2.6.3"] }

      assert_file "Gemfile" do |content|
        assert_match(/rubocop/, content)
        assert_match(/rubocop-rails/, content)
        assert_match(/rubocop-performance/, content)
      end

      assert_file ".rubocop.yml" do |content|
        assert_match("2.6.3", content)
        assert_match("AllCops", content)
      end
    end
  end
end
