# frozen_string_literal: true

require "test_helper"
require "generators/boring/ci/gitlab_ci/install/install_generator"

class GitlabCiInstallGeneratorTest < Rails::Generators::TestCase
  tests Boring::Ci::GitlabCi::InstallGenerator
  setup :build_app
  teardown :teardown_app

  include GeneratorHelper

  def destination_root
    app_path
  end

  def test_should_add_default_configurations
    Dir.chdir(app_path) do
      quietly { run_generator }

      assert_file(".gitlab-ci.yml") do |content|
        assert_match(/image: ruby:2.7.3/, content)
        assert_includes(content, "MASTER_KEY: $MASTER_KEY")
        assert_match(/cache:/, content)
        assert_match(/.base_db:/, content)
        assert_includes(content, "RAILS_ENV: test")
        assert_match(/unit_and_integration_tests:/, content)
        assert_includes(content, "bundle exec rails test")
        assert_match(/system_tests:/, content)
        assert_includes(content, "bundle exec rails test:system")
      end

      assert_file("config/database.yml.ci") do |content|
        assert_match(/adapter: sqlite3/, content)
        assert_match(%r{database: db/test.sqlite3}, content)
        refute_match(/username: test/, content)
        refute_match(/password: test/, content)
      end

      assert_file "test/helpers/capybara.rb"
      assert_file "test/application_system_test_case.rb" do |content|
        assert_match(%r{require "helpers/capybara"}, content)
        assert_match(/driven_by :selenium_chrome_custom/, content)
        assert_match(/Capybara.server_host/, content)
        assert_match(/Capybara.server_port/, content)
        assert_match(/Capybara.app_host/, content)
      end

      assert_file "test/models/sample_test.rb"
      assert_file "test/system/sample_test.rb"
    end
  end

  def test_should_add_configurations_for_rspec
    Dir.chdir(app_path) do
      add_rspec_files
      quietly { run_generator [destination_root, "--app_test_framework=rspec"] }

      assert_file(".gitlab-ci.yml") do |content|
        assert_includes(
          content,
          'bundle exec rspec --exclude-pattern "spec/system/**/*.rb"'
        )
        assert_includes(content, "bundle exec rspec spec/system")
      end

      assert_file "spec/support/capybara.rb" do |content|
        assert_match(/driven_by :selenium_chrome_custom/, content)
      end

      assert_file "spec/rails_helper.rb" do |content|
        assert_match(%r{require_relative \"./support/capybara\"}, content)
      end

      assert_file "spec/models/sample_spec.rb"
      assert_file "spec/system/sample_spec.rb"
    end
  end

  def test_should_add_configurations_for_postgresql
    Dir.chdir(app_path) do
      quietly { run_generator [destination_root, "--database=postgresql"] }

      assert_file(".gitlab-ci.yml") do |content|
        assert_match(/postgres:latest/, content)
        assert_match(/POSTGRES_HOST_AUTH_METHOD: trust/, content)
      end

      assert_file("config/database.yml.ci") do |content|
        assert_match(/adapter: postgresql/, content)
        refute_match(%r{database: db/test.sqlite3}, content)
        assert_match(/username: postgres/, content)
      end
    end
  end

  def test_should_add_configurations_for_mysql
    Dir.chdir(app_path) do
      quietly { run_generator [destination_root, "--database=mysql"] }

      assert_file(".gitlab-ci.yml") do |content|
        assert_match(/mysql:latest/, content)
      end

      assert_file("config/database.yml.ci") do |content|
        assert_match(/adapter: mysql2/, content)
        assert_match(/database: ci_db/, content)
        refute_match(%r{database: db/test.sqlite3}, content)
        assert_match(/username: root/, content)
      end
    end
  end

  def test_should_add_configurations_for_dotenv
    Dir.chdir(app_path) do
      quietly do
        run_generator [
                        destination_root,
                        "--environment_variable_manager=dotenv"
                      ]
      end

      assert_file(".gitlab-ci.yml") do |content|
        assert_includes(content, "cat $env > .env")
      end
    end
  end

  def test_should_add_configurations_for_figjam
    Dir.chdir(app_path) do
      quietly do
        run_generator [
                        destination_root,
                        "--environment_variable_manager=figjam"
                      ]
      end

      assert_file(".gitlab-ci.yml") do |content|
        assert_includes(content, "cat $env > config/application.yml")
      end
    end
  end

  def test_should_skip_sample_test_files
    Dir.chdir(app_path) do
      quietly { run_generator [destination_root, "--skip_sample_tests=true"] }

      assert_no_file "test/models/sample_test.rb"
      assert_no_file "test/system/sample_test.rb"
    end
  end

  private

  def add_rspec_files
    `mkdir spec`
    `touch spec/rails_helper.rb`
    `echo "RSpec.configure do |config|\nend\n" >> spec/rails_helper.rb`
  end
end
