# frozen_string_literal: true

require "test_helper"
require "generators/boring/rubocop/install/install_generator"

class RubocopTestFrameworkGemInstallGeneratorTest < Rails::Generators::TestCase
  tests Boring::Rubocop::InstallGenerator
  setup :build_app
  teardown :teardown_app

  include GeneratorHelper
  include ActiveSupport::Testing::Isolation

  def destination_root
    app_path
  end

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
