# frozen_string_literal: true

require "test_helper"
require "generators/boring/favicon/build/build_generator"

class FaviconBuildGeneratorTest < Rails::Generators::TestCase
  tests Boring::Favicon::BuildGenerator
  setup :build_app
  teardown :teardown_app

  include GeneratorHelper

  def destination_root
    app_path
  end

  def test_should_build_favicon_successfully
    Dir.chdir(app_path) do
      quietly { run_generator }

      assert_file "app/views/layouts/shared/_favicon.html.erb"
      assert_file "app/assets/images/favicons/apple-touch-icon-57x57.png"
      assert_file "app/assets/images/favicons/apple-touch-icon-60x60.png"
      assert_file "app/assets/images/favicons/apple-touch-icon-72x72.png"
      assert_file "app/assets/images/favicons/apple-touch-icon-76x76.png"
      assert_file "app/assets/images/favicons/apple-touch-icon-114x114.png"
      assert_file "app/assets/images/favicons/apple-touch-icon-120x120.png"
      assert_file "app/assets/images/favicons/apple-touch-icon-129x129.png"
      assert_file "app/assets/images/favicons/apple-touch-icon-144x144.png"
      assert_file "app/assets/images/favicons/apple-touch-icon-152x152.png"
      assert_file "app/assets/images/favicons/apple-touch-icon-120x120-precomposed.png"
      assert_file "app/assets/images/favicons/apple-touch-icon-129x129-precomposed.png"
      assert_file "app/assets/images/favicons/apple-touch-icon-152x152-precomposed.png"
      assert_file "app/assets/images/favicons/apple-touch-icon-precomposed.png"
      assert_file "app/assets/images/favicons/apple-touch-icon.png"
      assert_file "app/assets/images/favicons/favicon-16x16.ico"
      assert_file "app/assets/images/favicons/favicon-32x32.ico"
      assert_file "app/assets/images/favicons/mstile-144x144.png"

      assert_file "app/views/layouts/application.html.erb" do |content|
        assert_match "render 'layouts/shared/favicon'", content
      end
    end
  end

  def test_should_build_favicon_partial_with_application_name
    Dir.chdir(app_path) do
      quietly { run_generator [destination_root, "--application_name=boring_generators"] }

      assert_file "app/views/layouts/shared/_favicon.html.erb" do |content|
        assert_match /<meta.*content=.*boring_generators/, content
      end
    end
  end

  def test_should_build_favicon_with_given_primary_color
    Dir.chdir(app_path) do
      quietly { run_generator [destination_root, "--primary_color='#000000'"] }

      assert_file "app/views/layouts/shared/_favicon.html.erb" do |content|
        assert_match /<meta.*content=.*#000000/, content
      end
    end
  end

  def test_should_build_favicon_with_given_favico_letter
    Dir.chdir(app_path) do
      quietly { run_generator [destination_root, "--favico_letter='A'"] }

      assert_file "app/views/layouts/shared/_favicon.html.erb"
      assert_file "app/assets/images/favicons/apple-touch-icon-57x57.png"
      assert_file "app/assets/images/favicons/apple-touch-icon-60x60.png"
      assert_file "app/assets/images/favicons/apple-touch-icon-72x72.png"
      assert_file "app/assets/images/favicons/apple-touch-icon-76x76.png"
      assert_file "app/assets/images/favicons/apple-touch-icon-114x114.png"
      assert_file "app/assets/images/favicons/apple-touch-icon-120x120.png"
      assert_file "app/assets/images/favicons/apple-touch-icon-129x129.png"
      assert_file "app/assets/images/favicons/apple-touch-icon-144x144.png"
      assert_file "app/assets/images/favicons/apple-touch-icon-152x152.png"
      assert_file "app/assets/images/favicons/apple-touch-icon-120x120-precomposed.png"
      assert_file "app/assets/images/favicons/apple-touch-icon-129x129-precomposed.png"
      assert_file "app/assets/images/favicons/apple-touch-icon-152x152-precomposed.png"
      assert_file "app/assets/images/favicons/apple-touch-icon-precomposed.png"
      assert_file "app/assets/images/favicons/apple-touch-icon.png"
      assert_file "app/assets/images/favicons/favicon-16x16.ico"
      assert_file "app/assets/images/favicons/favicon-32x32.ico"
      assert_file "app/assets/images/favicons/mstile-144x144.png"
    end
  end
end
