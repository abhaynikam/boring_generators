# require_frozen_literal: true

require 'test_helper'
require 'generators/boring/rails_erd/install/install_generator'

class RailsErdInstallGeneratorTest < Rails::Generators::TestCase
  tests Boring::RailsErd::InstallGenerator
  setup :build_app
  teardown :teardown_app

  include GeneratorHelper

  def destination_root
    app_path
  end

  def test_should_configure_rails_erd_gem
    Dir.chdir(app_path) do
      quietly { run_generator }

      assert_gem 'rails-erd'

      assert_file 'lib/tasks/auto_generate_diagram.rake' do |content|
        assert_match(/RailsERD.load_tasks/, content)
      end
    end
  end
end