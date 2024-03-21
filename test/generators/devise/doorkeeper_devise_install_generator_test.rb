# frozen_string_literal: true

require "test_helper"
require "generators/boring/devise/doorkeeper/install/install_generator"

class DoorkeeperDeviseInstallGeneratorTest < Rails::Generators::TestCase
  tests Boring::Devise::Doorkeeper::InstallGenerator
  setup :build_app
  teardown :teardown_app

  include GeneratorHelper
  include ActiveSupport::Testing::Isolation

  def destination_root
    app_path
  end

  def test_should_exit_if_devise_is_not_installed
    assert_raises SystemExit do
      quietly { generator.verify_presence_of_devise_gem }
    end
  end

  def test_should_exit_if_devise_model_is_not_found
    assert_raises SystemExit do
      quietly { generator.verify_presence_of_devise_model }
    end
  end

  def test_should_setup_doorkeeper
    Dir.chdir(app_path) do
      setup_devise
      quietly { run_generator }

      assert_gem "doorkeeper"
      assert_file "config/locales/doorkeeper.en.yml"

      assert_file "config/initializers/doorkeeper.rb" do |content|
        assert_match(/resource_owner_authenticator do/, content)
        assert_match(/admin_authenticator do/, content)
        assert_match(/current_user || warden.authenticate!(scope: :user)/, content)
        assert_no_match(/# admin_authenticator do/, content)
        assert_match(/grant_flows %w\[authorization_code client_credentials\]/, content)
      end

      assert_migration "db/migrate/create_doorkeeper_tables.rb" do |content|
        assert_no_match(/# add_foreign_key :oauth/, content)
        assert_no_match(/<model>/, content)
        assert_match(/add_foreign_key :oauth_access_grants, :users, column: :resource_owner_id/, content)
        assert_match(/add_foreign_key :oauth_access_tokens, :users, column: :resource_owner_id/, content)
      end

      assert_file "config/routes.rb" do |content|
        assert_match(/use_doorkeeper/, content)
      end

      assert_file "app/models/user.rb" do |content|
        assert_match(/has_many :access_grants/, content)
        assert_match(/has_many :access_tokens/, content)
      end
    end
  end

  def test_should_setup_password_grant_flow
    Dir.chdir(app_path) do
      setup_devise
      quietly { run_generator %w[--grant_flows=password] }

      assert_migration "db/migrate/create_doorkeeper_tables.rb" do |content|
        assert_match(/t.text    :redirect_uri/, content)
      end

      assert_file "config/initializers/doorkeeper.rb" do |content|
        assert_match(/grant_flows %w\[password\]/, content)
        assert_match(/resource_owner_from_credentials do |routes|/, content)
        assert_match(/"Please configure doorkeeper resource_owner_authenticator block/, content)
      end
    end
  end

  def test_should_setup_api_only
    Dir.chdir(app_path) do
      setup_devise
      quietly { run_generator %w[--api_only] }

      assert_file "config/initializers/doorkeeper.rb" do |content|
        assert_match(/api_only/, content)
        assert_no_match(/# api_only/, content)
        assert_match(/# admin_authenticator do/, content)
      end
    end
  end

  def test_should_skip_applications_routes
    Dir.chdir(app_path) do
      setup_devise
      quietly { run_generator %w[--skip_applications_routes] }

      assert_file "config/routes.rb" do |content|
        assert_match(/use_doorkeeper do/, content)
        assert_match(/skip_controllers :applications, :authorized_applications/, content)
      end
    end
  end

  def test_should_use_refresh_token
    Dir.chdir(app_path) do
      setup_devise
      quietly { run_generator %w[--use_refresh_token] }

      assert_file "config/initializers/doorkeeper.rb" do |content|
        assert_match(/use_refresh_token/, content)
        assert_no_match(/# use_refresh_token/, content)
      end
    end
  end

  private

  def setup_devise(model_name: "User")
    Bundler.with_unbundled_env do
      `bundle add devise`
    end

    create_devise_initializer
    create_devise_model(model_name)
  end

  def create_devise_initializer
    FileUtils.mkdir_p("#{app_path}/config/initializers")
    content = <<~RUBY
      Devise.setup do |config|
      end
    RUBY

    File.write("#{app_path}/config/initializers/devise.rb", content)
  end

  def create_devise_model(model_name)
    FileUtils.mkdir_p("#{app_path}/app/models")
    content = <<~RUBY
      class #{model_name} < ApplicationRecord
      end
    RUBY

    File.write("#{app_path}/app/models/#{model_name.underscore}.rb", content)
  end
end

