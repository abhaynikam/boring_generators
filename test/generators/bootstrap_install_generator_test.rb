# frozen_string_literal: true

require "test_helper"
require "generators/boring/bootstrap/install/install_generator"

class BootstrapInstallGeneratorTest < Rails::Generators::TestCase
  tests Boring::Bootstrap::InstallGenerator
  setup :build_app
  teardown :teardown_app

  include GeneratorHelper

  def destination_root
    app_path
  end

  def test_should_install_bootstrap_successfully
    Dir.chdir(app_path) do
      quietly { run_generator }

      assert_file "package.json" do |content|
        assert_match(/popper/, content)
        assert_match(/bootstrap/, content)
        assert_match(/jquery/, content)
      end

      assert_file "config/webpack/environment.js" do |content|
        expected = <<~RUBY
          environment.plugins.append("Provide", new webpack.ProvidePlugin({
            $: 'jquery',
            jQuery: 'jquery',
            Popper: ['popper.js', 'default']
          }))
        RUBY

        assert_match(expected, content)
      end

      assert_file "app/javascript/stylesheets/application.scss" do |content|
        assert_match(/bootstrap\/scss\/bootstrap/, content)
      end

      assert_file "app/javascript/packs/application.js" do |content|
        assert_match(/stylesheets\/application/, content)
        assert_match(/bootstrap/, content)
      end

      assert_file "app/views/layouts/application.html.erb" do |content|
        assert_match(/stylesheet_pack_tag \'application\'/, content)
      end
    end
  end

  def test_should_warning_about_missing_application_js
    original_stdout = $stdout
    $stdout = StringIO.new

    Dir.chdir(app_path) do
      FileUtils.rm_rf("#{app_path}/app/javascript/packs/application.js")
      expected = "ERROR: Looks like the webpacker installation is incomplete. Could not find application.js in app/javascript/packs."
      generator.insert_stylesheet_in_the_application
      $stdout.rewind
      assert_match expected, $stdout.read
    end
  ensure
    $stdout = original_stdout
  end
end
