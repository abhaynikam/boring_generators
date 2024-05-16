# frozen_string_literal: true

module Boring
  module RackMiniProfiler
    class InstallGenerator < Rails::Generators::Base
      desc 'Adds rack mini profiler to the application'

      def add_rack_mini_profiler_gem
        say 'Adding rack mini profiler gem', :green

        gem 'rack-mini-profiler', require: false

        Bundler.with_unbundled_env do
          run 'bundle install'
        end
      end

      def configure_rack_mini_profiler
        say 'Configuring rack mini profiler', :green

        Bundler.with_unbundled_env do
          run 'bundle exec rails g rack_mini_profiler:install'
        end
      end
    end
  end
end
