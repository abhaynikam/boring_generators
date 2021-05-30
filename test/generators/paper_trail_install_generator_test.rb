# frozen_string_literal: true

require "test_helper"
require "generators/boring/paper_trail/install/install_generator"

class PaperTrailInstallGeneratorTest < Rails::Generators::TestCase
  tests Boring::PaperTrail::InstallGenerator
  setup :build_app
  teardown :teardown_app

  include GeneratorHelper
  include ActiveSupport::Testing::Isolation

  def destination_root
    app_path
  end

  def test_should_install_paper_trail_successfully
    Dir.chdir(app_path) do
      quietly { run_generator [destination_root, "--route_name='admin'"] }

      assert_gem "paper_trail"
      assert_migration "db/migrate/create_versions.rb"
      assert_migration "db/migrate/add_object_changes_to_versions.rb"
      assert_file "app/controllers/application_controller.rb" do |content|
        assert_match(/before_action :set_paper_trail_whodunnit/, content)
      end
    end
  end

  def test_should_install_paper_trail_without_running_generator_successfully
    Dir.chdir(app_path) do
      quietly { run_generator [destination_root, "--skip_generator"] }

      assert_gem "paper_trail"
      assert_no_migration "db/migrate/create_versions.rb"
      assert_no_migration "db/migrate/add_object_changes_to_versions.rb"
      assert_file "app/controllers/application_controller.rb" do |content|
        assert_match(/before_action :set_paper_trail_whodunnit/, content)
      end
    end
  end

  def test_should_install_paper_trail_without_adding_tracking_for_whodunnit
    Dir.chdir(app_path) do
      quietly { run_generator [destination_root, "--skip_user_track_config"] }

      assert_gem "paper_trail"
      assert_migration "db/migrate/create_versions.rb"
      assert_migration "db/migrate/add_object_changes_to_versions.rb"
      assert_file "app/controllers/application_controller.rb" do |content|
        assert_no_match(/before_action :set_paper_trail_whodunnit/, content)
      end
    end
  end
end
