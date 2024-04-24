# frozen_string_literal: true

require "test_helper"
require "generators/boring/sidekiq/install/install_generator"

class SidekiqInstallGeneratorTest < Rails::Generators::TestCase
  tests Boring::Sidekiq::InstallGenerator
  setup :build_app
  teardown :teardown_app

  include GeneratorHelper
  include ActiveSupport::Testing::Isolation

  def destination_root
    app_path
  end

  def test_should_configure_sidekiq
    Dir.chdir(app_path) do
      add_procfile
      quietly { run_generator }

      assert_gem "sidekiq"
      assert_file "config/application.rb" do |content|
        assert_match(/config\.active_job\.queue_adapter = :sidekiq/, content)
      end
      assert_file "config/routes.rb" do |content|
        assert_match(/require 'sidekiq\/web'/, content)
        assert_match(/mount Sidekiq::Web/, content)
      end

      assert_file "Procfile.dev" do |content|
        assert_match(/worker: bundle exec sidekiq/, content)
      end
    end
  end

  def test_should_skip_sidekiq_routes
    Dir.chdir(app_path) do
      quietly { run_generator %w[--skip-routes] }

      assert_file "config/routes.rb" do |content|
        assert_no_match(/mount Sidekiq::Web/, content)
      end
    end
  end

  def test_should_authenticate_routes_with_devise
    Dir.chdir(app_path) do
      quietly { run_generator %w[--authenticate_routes_with_devise] }

      assert_file "config/routes.rb" do |content|
        assert_match(/authenticate :user do/, content)
        assert_match(/mount Sidekiq::Web/, content)
      end
    end
  end

  def test_should_skip_adding_sidekiq_worker_to_procfile
    Dir.chdir(app_path) do
      add_procfile
      quietly { run_generator %w[--skip_procfile_config] }
      
      assert_file "Procfile.dev" do |content|
        assert_no_match(/worker: bundle exec sidekiq/, content)
      end
    end
  end

  private

  def add_procfile
    File.write("#{app_path}/Procfile.dev", "web: bin/rails server -p 3000 -b 0.0.0.0")
  end
end
