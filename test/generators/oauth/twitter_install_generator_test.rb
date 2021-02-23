# frozen_string_literal: true

require "test_helper"
require "generators/boring/devise/install/install_generator"
require "generators/boring/oauth/twitter/install/install_generator"

class OauthTwitterInstallGeneratorTest < Rails::Generators::TestCase
  tests Boring::Oauth::Twitter::InstallGenerator
  setup :build_app
  teardown :teardown_app

  include GeneratorHelper
  include ActiveSupport::Testing::Isolation

  def destination_root
    app_path
  end

  def test_should_install_twitter_oauth
    Dir.chdir(app_path) do
      quietly { Rails::Generators.invoke("boring:devise:install") }
      quietly { run_generator }

      assert_gem "omniauth-twitter"
      assert_migration "db/migrate/add_omniauth_to_users.rb"
      assert_file "config/initializers/devise.rb" do |content|
        assert_match('config.omniauth :twitter', content)
      end

      assert_file "app/controllers/users/omniauth_callbacks_controller.rb"

      assert_file "app/models/user.rb" do |content|
        assert_match('devise :omniauthable, omniauth_providers: %i[twitter]', content)
        assert_match('def self.from_omniauth(auth)', content)
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
