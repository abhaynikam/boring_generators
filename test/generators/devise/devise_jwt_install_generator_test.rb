# frozen_string_literal: true

require "test_helper"
require "generators/boring/devise/jwt/install/install_generator"

class DeviseInstallGeneratorTest < Rails::Generators::TestCase
  tests Boring::Devise::Jwt::InstallGenerator
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

  def test_should_exit_if_devise_initializer_is_not_present
    assert_raises SystemExit do
      quietly { generator.verify_presence_of_devise_initializer }
    end
  end

  def test_should_exit_if_devise_model_is_not_present
    assert_raises SystemExit do
      quietly { generator.verify_presence_of_devise_model }
    end
  end

  def test_should_configure_devise_jwt
    Dir.chdir(app_path) do
      setup_devise
      quietly { run_generator }
      assert_gem "devise-jwt"
      assert_file "config/initializers/devise.rb" do |content|
        assert_match(/config.jwt do |jwt|/, content)
        assert_match(/jwt.secret = Rails.application.credentials.devise_jwt_secret/, content)
        assert_match(/jwt\.dispatch_requests\s*=\s*\[\s*/, content)
        assert_match(/jwt\.revocation_requests\s*=\s*\[\s*/, content)
        assert_match(/jwt\.expiration_time\s*=\s*/, content)
      end
      assert_migration "db/migrate/create_jwt_denylist.rb"
      assert_file "app/models/user.rb" do |content|
        assert_match(
          /devise\s*(?:(?:(?::\w+)|(?:\w+:\s*\w+))(?:(?:,\s*:\w+)|(?:,\s*\w+:\s*\w+))*)*(?:,\s*:jwt_authenticatable, jwt_revocation_strategy: JwtDenylist)/,
          content
        )
      end

      assert_file "app/models/jwt_denylist.rb" do |content|
        assert_match(/include Devise::JWT::RevocationStrategies::Denylist/, content)
        assert_match(/self\.table_name = 'jwt_denylist'/, content)
      end
    end
  end

  def test_should_use_env_variable_for_devise_jwt_secret
    Dir.chdir(app_path) do
      setup_devise
      quietly { run_generator [destination_root, "--use_env_variable"] }
      assert_file "config/initializers/devise.rb" do |content|
        assert_match(/jwt\.secret\s*=\s*ENV\['DEVISE_JWT_SECRET_KEY'\]/, content)
      end
    end
  end

  def test_should_configure_jti_matcher_revocation_strategy
    Dir.chdir(app_path) do
      setup_devise
      quietly { run_generator [destination_root, "--revocation_strategy=JTIMatcher"] }
      assert_migration "db/migrate/add_jti_to_users.rb"
      assert_file "app/models/user.rb" do |content|
        assert_match(/include Devise::JWT::RevocationStrategies::JTIMatcher/, content)
        assert_match(
          /devise\s*(?:(?:(?::\w+)|(?:\w+:\s*\w+))(?:(?:,\s*:\w+)|(?:,\s*\w+:\s*\w+))*)*(?:,\s*:jwt_authenticatable, jwt_revocation_strategy: self)/,
          content
        )
      end
    end
  end

  def test_should_configure_allowlist_revocation_strategy
    Dir.chdir(app_path) do
      setup_devise
      quietly { run_generator [destination_root, "--revocation_strategy=Allowlist"] }
      assert_migration "db/migrate/create_allowlisted_jwts.rb"
      assert_file "app/models/user.rb" do |content|
        assert_match(/include Devise::JWT::RevocationStrategies::Allowlist/, content)
        assert_match(
          /devise\s*(?:(?:(?::\w+)|(?:\w+:\s*\w+))(?:(?:,\s*:\w+)|(?:,\s*\w+:\s*\w+))*)*(?:,\s*:jwt_authenticatable, jwt_revocation_strategy: self)/,
          content
        )
      end
      assert_file "app/models/allowlisted_jwt.rb"
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
         devise :database_authenticatable, :registerable,
                :recoverable, :rememberable, :validatable
      end
    RUBY
  
    File.write("#{app_path}/app/models/#{model_name.underscore}.rb", content)
  end
end
