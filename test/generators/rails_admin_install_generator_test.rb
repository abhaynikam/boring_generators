# frozen_string_literal: true

require "test_helper"
require "generators/boring/rails_admin/install/install_generator"

class RailsAdminInstallGeneratorTest < Rails::Generators::TestCase
  tests Boring::RailsAdmin::InstallGenerator
  setup :build_app
  teardown :teardown_app

  include GeneratorHelper
  include ActiveSupport::Testing::Isolation

  def destination_root
    app_path
  end

  def test_should_install_rails_admin_successfully
    Dir.chdir(app_path) do
      quietly { run_generator [destination_root, "--route_name='admin'"] }

      assert_gem "rails_admin"
      assert_file "config/initializers/rails_admin.rb"
      assert_file "config/routes.rb" do |content|
        assert_match(/mount RailsAdmin::Engine/, content)
      end
    end
  end

  def test_should_install_rails_admin_without_running_generator_successfully
    Dir.chdir(app_path) do
      quietly { run_generator [destination_root, "--skip_generator"] }

      assert_gem "rails_admin"
      assert_no_file "config/initializers/rails_admin.rb"
      assert_file "config/routes.rb" do |content|
        assert_no_match(/mount RailsAdmin::Engine/, content)
      end
    end
  end
end
