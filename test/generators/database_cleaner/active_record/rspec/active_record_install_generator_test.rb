# frozen_string_literal: true

require 'test_helper'
require 'generators/boring/database_cleaner/active_record/rspec/install/install_generator'

class DatabaseCleanerActiveRecordInstallGeneratorTest < Rails::Generators::TestCase
  tests Boring::DatabaseCleaner::ActiveRecord::Rspec::InstallGenerator
  setup :build_app
  teardown :teardown_app

  include GeneratorHelper
  include ActiveSupport::Testing::Isolation

  def destination_root
    app_path
  end

  def test_should_exit_if_rspec_is_not_installed
    assert_raises SystemExit do
      quietly { generator.verify_presence_of_rspec_gem }
    end
  end

  def test_should_exit_if_rails_helper_is_not_present
    assert_raises SystemExit do
      quietly { generator.verify_presence_of_rails_helper }
    end
  end

  def test_should_add_database_cleaner_active_record_gem
    Dir.chdir(app_path) do
      configure_rspec

      quietly { run_generator }

      assert_gem 'database_cleaner-active_record'
    end
  end

  def test_should_configure_database_cleaner_with_rspec
    database_cleaner_template_content = read_database_cleaner_template
    Dir.chdir(app_path) do
      configure_rspec

      quietly { run_generator }

      database_cleaner_content = File.read('spec/support/database_cleaner.rb')
      assert_equal database_cleaner_template_content, database_cleaner_content

      assert_file 'spec/rails_helper.rb' do |content|
        assert_match(/require 'support\/database_cleaner'/, content)
        assert_match(/config\.use_transactional_fixtures = false/, content)
      end
    end
  end

  def test_should_skip_capybara_configs
    database_cleaner_template_content = read_database_cleaner_template(skip_capybara_configs: true)
    Dir.chdir(app_path) do
      configure_rspec

      quietly { run_generator [destination_root, "--skip_capybara_configs"] }
      database_cleaner_content = File.read('spec/support/database_cleaner.rb')
      assert_equal database_cleaner_template_content, database_cleaner_content
      assert_file 'spec/rails_helper.rb' do |content|
        assert_match(/config\.use_transactional_fixtures = true/, content)
      end
    end
  end

  private

  def configure_rspec
    Bundler.with_unbundled_env do
      `bundle add rspec-rails --group development,test`
    end

    create_rails_helper
  end

  def create_rails_helper
    FileUtils.mkdir_p("#{app_path}/spec")
    content = <<~RUBY
      RSpec.configure do |config|
        config.use_transactional_fixtures = true
      end
    RUBY

    File.write("#{app_path}/spec/rails_helper.rb", content)
  end

  def read_database_cleaner_template(skip_capybara_configs: false)
    @skip_capybara_configs = skip_capybara_configs
    template_path = File.join(
      GEM_ROOT,
      "lib/generators/boring/database_cleaner/active_record/rspec/install/templates/database_cleaner.rb.tt"
    )
    ERB.new(File.read(template_path), trim_mode: '-').result(binding)
  end
end
