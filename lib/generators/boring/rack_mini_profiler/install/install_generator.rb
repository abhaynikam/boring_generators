# frozen_string_literal: true

module Boring
  module RackMiniProfiler
    class InstallGenerator < Rails::Generators::Base
      desc 'Adds rack-mini-profiler to the application'

      def add_rack_mini_profiler_gem
        say 'Adding rack-mini-profiler gem', :green
        gem_definition = "gem 'rack-mini-profiler', require: false\n"
        rack_mini_profiler_gems_content = <<~RUBY
        \n
        \t# Profiler for your Rails application
        \tgem 'rack-mini-profiler', require: false
        RUBY

        insert_into_file "Gemfile", rack_mini_profiler_gems_content, after: /group :development do\n/

        bundle_install
      end

      def configure_rack_mini_profiler
        say 'Configuring rack mini profiler', :green
        run_with_bundler 'bundle exec rails g rack_mini_profiler:install'
      end

      private

      def bundle_install
        run_with_bundler 'bundle install'
      end

      def run_with_bundler(command)
        Bundler.with_unbundled_env do
          run command
        end
      end
    end
  end
end
