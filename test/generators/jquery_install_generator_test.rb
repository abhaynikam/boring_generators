# frozen_string_literal: true

require "test_helper"
require "generators/boring/jquery/install/install_generator"

class JqueryInstallGeneratorTest < Rails::Generators::TestCase
  tests Boring::Jquery::InstallGenerator
  setup :build_app
  teardown :teardown_app

  include GeneratorHelper

  def destination_root
    app_path
  end

  def test_should_install_jquery_successfully
    Dir.chdir(app_path) do
      quietly { run_generator }

      assert_file "package.json" do |content|
        assert_match(/jquery/, content)
      end

      assert_file "config/webpack/environment.js" do |content|
        expected = <<~RUBY
          environment.plugins.append("Provide", new webpack.ProvidePlugin({
            $: 'jquery',
            jQuery: 'jquery'
          }))
        RUBY

        assert_match(expected, content)
      end
    end
  end

  def test_should_warning_about_missing_webpacker_env_file
    original_stdout = $stdout
    $stdout = StringIO.new

    Dir.chdir(app_path) do
      FileUtils.rm_rf("#{app_path}/config/webpack/environment.js")
      expected = "ERROR: Looks like the webpacker installation is incomplete. Could not find environment.js in config/webpack."
      generator.add_jquery_plugin_provider_to_webpack_environment
      $stdout.rewind
      assert_match expected, $stdout.read
    end
  ensure
    $stdout = original_stdout
  end
end
