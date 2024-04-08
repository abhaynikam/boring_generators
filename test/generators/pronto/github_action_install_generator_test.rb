# frozen_string_literal: true

require "test_helper"
require "generators/boring/pronto/github_action/install/install_generator"

class ProntoGithubActionInstallGeneratorTest < Rails::Generators::TestCase
  tests Boring::Pronto::GithubAction::InstallGenerator
  setup :build_app
  teardown :teardown_app

  include GeneratorHelper
  include ActiveSupport::Testing::Isolation

  def destination_root
    app_path
  end

  def test_should_configure_pronto_in_github_action_file
    Dir.chdir(app_path) do
      quietly do
        generator.add_pronto_configuration_for_github_action
      end

      template_app_ruby_version = `cat .ruby-version`

      assert_file ".github/workflows/pronto.yml" do |content|
        assert_match("pronto:", content)
        assert_match("ruby-version: #{template_app_ruby_version}", content)
      end
    end
  end

  def test_should_add_correct_ruby_version
    Dir.chdir(app_path) do
      quietly do
        generator({}, [ "--ruby_version=3.0.0" ])
          .add_pronto_configuration_for_github_action
      end

      assert_file ".github/workflows/pronto.yml" do |content|
        assert_match("ruby-version: 3.0.0", content)
      end
    end
  end
end
