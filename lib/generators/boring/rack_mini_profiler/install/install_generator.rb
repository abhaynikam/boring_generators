# frozen_string_literal: true

require 'boring_generators/generator_helper'

module Boring
  module RackMiniProfiler
    class InstallGenerator < Rails::Generators::Base
      include BoringGenerators::GeneratorHelper
      
      desc "Adds rack-mini-profiler to the application"

      def add_rack_mini_profiler_gem
        say "Adding rack-mini-profiler gem", :green
        
        return if gem_installed?("rack-mini-profiler")

        rack_mini_profiler_gems_content = <<~RUBY
        \t# Profiler for your Rails application
        \tgem 'rack-mini-profiler', require: false\n
        RUBY

        insert_into_file "Gemfile",
                         rack_mini_profiler_gems_content,
                         after: /group :development do\n/

        Bundler.with_unbundled_env { run "bundle install" }
      end

      def configure_rack_mini_profiler
        say "Configuring rack mini profiler", :green

        Bundler.with_unbundled_env do
          run "bundle exec rails g rack_mini_profiler:install"
        end
      end
    end
  end
end
