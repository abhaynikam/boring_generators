# frozen_string_literal: true

require "test_helper"
require "generators/boring/vcr/install/install_generator"

class VcrInstallGeneratorTest < Rails::Generators::TestCase
  tests Boring::Vcr::InstallGenerator
  setup :build_app
  teardown :teardown_app

  include GeneratorHelper
  include ActiveSupport::Testing::Isolation

  def destination_root
    app_path
  end

  def test_should_exit_if_rails_helper_is_not_present
    assert_raises SystemExit do
      quietly { run_generator }
    end
  end

  def test_should_configure_vcr
    Dir.chdir(app_path) do
      configure_rspec
      quietly { run_generator }

      assert_gem "vcr"
      assert_gem "webmock"
      assert_file "spec/support/vcr.rb" do |content|
        assert_match(/require "vcr"/, content)
        assert_match(/VCR.configure do |c|/, content)
        assert_match(/c.hook_into :webmock/, content)
        assert_match(/c.configure_rspec_metadata!/, content)
      end

      assert_file 'spec/rails_helper.rb' do |content|
        assert_match(/require 'support\/vcr'/, content)
      end
    end
  end

  def test_should_configure_vcr_for_minitest
    Dir.chdir(app_path) do
      quietly { run_generator %w[--testing_framework=minitest] }

      assert_file "test/test_helper.rb" do |content|
        assert_match(/require "vcr"/, content)
        assert_match(/VCR.configure do |c|/, content)
        assert_match(/c.hook_into :webmock/, content)
        assert_no_match(/c.configure_rspec_metadata!/, content)
      end
    end
  end

  def test_should_configure_vcr_with_correct_stubbing_libraries
    Dir.chdir(app_path) do
      configure_rspec
      quietly { run_generator %w[--stubbing_libraries=webmock typhoeus] }

      assert_gem "webmock"
      assert_gem "typhoeus"

      assert_file "spec/support/vcr.rb" do |content|
        assert_match(/c.hook_into :webmock, :typhoeus/, content)
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
end
