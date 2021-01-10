# frozen_string_literal: true

require "test_helper"
require "generators/boring/devise/install/install_generator"
require "generators/boring/oauth/facebook/install/install_generator"

class OauthFacebookInstallGeneratorTest < Rails::Generators::TestCase
  tests Boring::Oauth::Facebook::InstallGenerator
  setup :build_app
  teardown :teardown_app

  include GeneratorHelper
  include ActiveSupport::Testing::Isolation

  def destination_root
    app_path
  end

  def test_should_install_facebook_oauth
    Dir.chdir(app_path) do
      quietly { Rails::Generators.invoke("boring:devise:install") }
      quietly { run_generator }

      assert_gem "omniauth-facebook"
      assert_migration "db/migrate/add_omniauth_to_users.rb"
      assert_file "config/initializers/devise.rb" do |content|
        assert_match('config.omniauth :facebook', content)
      end

      assert_file "app/controllers/users/omniauth_callbacks_controller.rb"

      assert_file "app/models/user.rb" do |content|
        assert_match('devise :omniauthable, omniauth_providers: %i[facebook]', content)
        assert_match('def self.from_omniauth(auth)', content)
      end

      assert_file "app/views/users/sessions/new.html.erb" do |content|
        assert_match('Sign in with Facebook', content)
      end
    end
  end

  def test_should_raise_devise_configuration_missing_error
    Dir.chdir(app_path) do
      assert_raises do
        run_generator
      end
    end
  end
end
