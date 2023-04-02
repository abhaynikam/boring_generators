# frozen_string_literal: true

require "test_helper"
require "generators/boring/overcommit/base_generator"

class OvercommitBaseGeneratorTest < Rails::Generators::TestCase
  tests Boring::Overcommit::BaseGenerator
  setup :build_app_with_git
  teardown :teardown_app

  include GeneratorHelper
  include ActiveSupport::Testing::Isolation

  def destination_root
    app_path
  end

  def test_should_configure_gem
    Dir.chdir(app_path) do
      quietly { run_generator }

      assert_file "Gemfile" do |content|
        assert_match("overcommit", content)
      end

      assert_file ".overcommit.yml"
    end
  end

  def test_should_skip_gem
    original_stdout = $stdout
    $stdout = StringIO.new

    Dir.chdir(app_path) do
      expected = "Overcommit gem is already installed!"

      quietly do
        generator.add_overcommit_gem

        generator.add_overcommit_gem
      end

      $stdout.rewind

      assert_match expected, $stdout.read
    end
  ensure
    $stdout = original_stdout
  end
end
