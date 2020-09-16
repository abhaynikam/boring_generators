# frozen_string_literal: true

require "test_helper"
require "generators/boring/bullet/install/install_generator"

class BulletInstallGeneratorTest < Rails::Generators::TestCase
  tests Boring::Bullet::InstallGenerator
  setup :build_app
  teardown :teardown_app

  include GeneratorHelper

  def destination_root
    app_path
  end

  def test_should_install_bullet_successfully
    Dir.chdir(app_path) do
      quietly { run_generator }

      assert_file "Gemfile" do |content|
        assert_match(/bullet/, content)
      end

      assert_file "config/initializers/bullet.rb"
    end
  end

  def test_should_skip_adding_bullet_configuration
    Dir.chdir(app_path) do
      quietly { run_generator [destination_root, "--skip_configuration"] }

      assert_no_file "config/initializers/bullet.rb"
    end
  end
end
