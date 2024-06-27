# frozen_string_literal: true

require "test_helper"
require "generators/boring/devise/install/install_generator"

class DeviseInstallGeneratorTest < Rails::Generators::TestCase
  tests Boring::Devise::InstallGenerator
  setup :build_app
  teardown :teardown_app

  include GeneratorHelper
  include ActiveSupport::Testing::Isolation

  def destination_root
    app_path
  end

  def test_should_install_devise_successfully
    Dir.chdir(app_path) do
      quietly { run_generator }

      assert_gem "devise"
      assert_file "config/environments/development.rb" do |content|
        assert_match(/config.action_mailer.default_url_options/, content)
      end

      assert_file "config/initializers/devise.rb"
      assert_file "config/locales/devise.en.yml"
      assert_migration "db/migrate/devise_create_users.rb"
      assert_file "app/models/user.rb"
      assert_file "app/views/users/shared/_error_messages.html.erb"
      assert_file "app/views/users/confirmations/new.html.erb"
      assert_file "app/views/users/passwords/edit.html.erb"
      assert_file "app/views/users/passwords/new.html.erb"
      assert_file "app/views/users/registrations/edit.html.erb"
      assert_file "app/views/users/registrations/new.html.erb"
      assert_file "app/views/users/sessions/new.html.erb"
      assert_file "app/views/users/unlocks/new.html.erb"
      assert_file "app/views/users/mailer/confirmation_instructions.html.erb"
      assert_file "app/views/users/mailer/email_changed.html.erb"
      assert_file "app/views/users/mailer/password_change.html.erb"
      assert_file "app/views/users/mailer/reset_password_instructions.html.erb"
      assert_file "app/views/users/mailer/unlock_instructions.html.erb"
    end
  end

  def test_should_skip_devise_views
    Dir.chdir(app_path) do
      quietly { run_generator [destination_root, "--skip_devise_view"] }

      assert_gem "devise"
      assert_file "config/environments/development.rb" do |content|
        assert_match(/config.action_mailer.default_url_options/, content)
      end

      assert_file "config/initializers/devise.rb"
      assert_file "config/locales/devise.en.yml"
      assert_migration "db/migrate/devise_create_users.rb"
      assert_file "app/models/user.rb"
      assert_no_file "app/views/users/shared/_error_messages.html.erb"
      assert_no_file "app/views/users/confirmations/new.html.erb"
      assert_no_file "app/views/users/passwords/edit.html.erb"
      assert_no_file "app/views/users/passwords/new.html.erb"
      assert_no_file "app/views/users/registrations/edit.html.erb"
      assert_no_file "app/views/users/registrations/new.html.erb"
      assert_no_file "app/views/users/sessions/new.html.erb"
      assert_no_file "app/views/users/unlocks/new.html.erb"
      assert_no_file "app/views/users/mailer/confirmation_instructions.html.erb"
      assert_no_file "app/views/users/mailer/email_changed.html.erb"
      assert_no_file "app/views/users/mailer/password_change.html.erb"
      assert_no_file "app/views/users/mailer/reset_password_instructions.html.erb"
      assert_no_file "app/views/users/mailer/unlock_instructions.html.erb"
    end
  end

  def test_should_skip_devise_model
    Dir.chdir(app_path) do
      quietly { run_generator [destination_root, "--skip_devise_model"] }

      assert_gem "devise"
      assert_file "config/environments/development.rb" do |content|
        assert_match(/config.action_mailer.default_url_options/, content)
      end

      assert_file "config/initializers/devise.rb"
      assert_file "config/locales/devise.en.yml"
      assert_no_migration "db/migrate/devise_create_users.rb"
      assert_no_file "app/models/user.rb"
      assert_file "app/views/users/shared/_error_messages.html.erb"
      assert_file "app/views/users/confirmations/new.html.erb"
      assert_file "app/views/users/passwords/edit.html.erb"
      assert_file "app/views/users/passwords/new.html.erb"
      assert_file "app/views/users/registrations/edit.html.erb"
      assert_file "app/views/users/registrations/new.html.erb"
      assert_file "app/views/users/sessions/new.html.erb"
      assert_file "app/views/users/unlocks/new.html.erb"
      assert_file "app/views/users/mailer/confirmation_instructions.html.erb"
      assert_file "app/views/users/mailer/email_changed.html.erb"
      assert_file "app/views/users/mailer/password_change.html.erb"
      assert_file "app/views/users/mailer/reset_password_instructions.html.erb"
      assert_file "app/views/users/mailer/unlock_instructions.html.erb"
    end
  end

  def test_should_run_db_migrate
    Dir.chdir(app_path) do
      `rails db:migrate`

      generator = generator({}, ['--run_db_migrate=true'])

      quietly do
        generator.add_devise_gem
        generator.generating_devise_defaults
        generator.add_devise_user_model
      end

      pending_migrations = `rails db:migrate:status | awk '$1 == "down"'`

      assert_includes pending_migrations, "down"

      quietly { generator({}, ['--run_db_migrate=true']).run_db_migrate }

      pending_migrations = `rails db:migrate:status | awk '$1 == "down"'`

      assert_empty pending_migrations

      `rails db:rollback`
    end
  end
end
