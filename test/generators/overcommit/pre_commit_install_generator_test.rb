# frozen_string_literal: true

require "test_helper"
require "generators/boring/overcommit/pre_commit/rubocop/install/install_generator"

class OvercommitPreCommitInstallGeneratorTest < Rails::Generators::TestCase
  tests Boring::Overcommit::PreCommit::Rubocop::InstallGenerator
  setup :build_app_with_git
  teardown :teardown_app

  include GeneratorHelper
  include ActiveSupport::Testing::Isolation

  def destination_root
    app_path
  end

  def test_should_configure_rubocop
    Dir.chdir(app_path) do
      Bundler.with_unbundled_env do
        `bundle add rubocop --group development`
      end

      quietly { run_generator }

      assert_file ".overcommit.yml" do |content|
        configuration_content = <<~YAML
          PreCommit:
            RuboCop:
              enabled: true
              on_warn: fail # Treat all warnings as failures
              problem_on_unmodified_line: ignore # run RuboCop only on modified code'
        YAML

        assert_match(configuration_content, content)
      end
    end
  end

  def test_should_throw_pre_commit_errors
    Dir.chdir(app_path) do
      Bundler.with_unbundled_env do
        `bundle add rubocop --group development`
      end

      `git add . && git commit -m "Initial setup"`

      quietly { run_generator }

      `touch app/models/role.rb`

      file_path = "#{app_path}/app/models/role.rb"

      class_with_rubocop_errors = <<~RUBY
        class Role
          DEFAULT_ROLE = "admin"
        end
      RUBY

      File.open(file_path, 'w+') do |file|
        file.write(class_with_rubocop_errors)
      end

      pre_commit_errors = ''

      Bundler.with_unbundled_env do
        quietly do
          pre_commit_errors = `git add app/models/role.rb && git commit -m "Pre commit hook configured with overcommit gem"`
        end
      end

      assert_empty pre_commit_errors
    end
  end

  def test_should_exit_if_rubocop_is_not_installed
    original_stdout = $stdout
    $stdout = StringIO.new

    Dir.chdir(app_path) do
      expected = "rubocop gem is not installed. Please install it and run the generator again!"

      quietly { generator.configure_rubocop }

      $stdout.rewind

      assert_match expected, $stdout.read
    end
  ensure
    $stdout = original_stdout
  end
end
