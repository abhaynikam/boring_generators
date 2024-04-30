# frozen_string_literal: true

require "test_helper"
require "generators/boring/annotate/install/install_generator"

class AnnotateInstallGeneratorTest < Rails::Generators::TestCase
  tests Boring::Annotate::InstallGenerator
  setup :build_app
  teardown :teardown_app

  include GeneratorHelper
  include ActiveSupport::Testing::Isolation

  def destination_root
    app_path
  end

  def test_should_configure_annotate
    Dir.chdir(app_path) do
      quietly { run_generator }

      assert_gem 'annotate'

      assert_file "lib/tasks/auto_annotate_models.rake" do |content|
        assert_match(/Annotate\.load_tasks/, content)
        assert_match("      'skip_on_db_migrate'          => 'false'", content,)
      end
    end
  end

  def test_should_set_skip_on_db_migrate_to_true
    Dir.chdir(app_path) do
      quietly { run_generator %w[--skip_on_db_migrate] }

      assert_file "lib/tasks/auto_annotate_models.rake" do |content|
        assert_match("      'skip_on_db_migrate'          => 'true'", content,)
      end
    end
  end
end
