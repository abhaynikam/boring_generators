# frozen_string_literal: true

require 'test_helper'
require 'generators/boring/rack_mini_profiler/install/install_generator'

class RackMiniProfilerGeneratorTest < Rails::Generators::TestCase
  tests Boring::RackMiniProfiler::InstallGenerator
  setup :build_app
  teardown :teardown_app

  include GeneratorHelper

  def destination_root
    app_path
  end

  def test_should_configure_rack_mini_profiler_gem
    Dir.chdir(app_path) do
      quietly { run_generator }

      assert_file 'Gemfile' do |content|
        assert_match(/gem 'rack-mini-profiler', require: false/, content)
      end

      assert_file 'config/initializers/rack_mini_profiler.rb' do |content|
        assert_match(/if Rails\.env\.development\?/, content)
        assert_match(/Rack::MiniProfilerRails.initialize!\(Rails.application\)/, content)
      end
    end
  end
end
