# frozen_string_literal: true

require "test_helper"
require "generators/boring/pronto/base_generator"

class ProntoBaseGeneratorTest < Rails::Generators::TestCase
  tests Boring::Pronto::BaseGenerator
  setup :build_app
  teardown :teardown_app

  include GeneratorHelper
  include ActiveSupport::Testing::Isolation

  def destination_root
    app_path
  end

  def test_should_install_pronto_with_all_extension_gems
    Dir.chdir(app_path) do
      quietly { run_generator  }

      assert_file "Gemfile" do |content|
        assert_match("pronto", content)
        assert_match("pronto-brakeman", content)
        assert_match("pronto-flay", content)
        assert_match("pronto-reek", content)
        assert_match("pronto-rubocop", content)
      end
    end
  end

  def test_should_skip_brakeman_extension
    Dir.chdir(app_path) do
      quietly do
        generator({}, ['--extensions_to_skip=brakeman']).add_brakeman_extension
      end

      assert_file "Gemfile" do |content|
        refute_match("pronto-brakeman", content)
      end
    end
  end

  def test_should_skip_flay_extension
    Dir.chdir(app_path) do
      quietly do
        generator({}, ['--extensions_to_skip=flay']).add_flay_extension
      end

      assert_file "Gemfile" do |content|
        refute_match("pronto-flay", content)
      end
    end
  end

  def test_should_skip_reek_extension
    Dir.chdir(app_path) do
      quietly do
        generator({}, ['--extensions_to_skip=reek']).add_reek_extension
      end

      assert_file "Gemfile" do |content|
        refute_match("pronto-reek", content)
      end
    end
  end

  def test_should_skip_rubocop_extension
    Dir.chdir(app_path) do
      quietly do
        generator({}, ['--extensions_to_skip=rubocop']).add_rubocop_extension
      end

      assert_file "Gemfile" do |content|
        refute_match("pronto-rubocop", content)
      end
    end
  end

  def test_should_skip_multiple_extensions
    Dir.chdir(app_path) do
      quietly do
        generator({}, ['--extensions_to_skip=reek', 'rubocop']).add_rubocop_extension
      end

      assert_file "Gemfile" do |content|
        refute_match("pronto-reek", content)
        refute_match("pronto-rubocop", content)
      end
    end
  end
end
