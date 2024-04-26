# frozen_string_literal: true

require 'boring_generators/generator_helper'

module Boring
  module RailsErd
    class InstallGenerator < Rails::Generators::Base
      include BoringGenerators::GeneratorHelper

      desc 'Adds rails-erd gem to the  app for generating ERD diagrams'

      def add_rails_erd_gem
        if gem_installed?("rails-erd")
          say "rails-erd is already in the Gemfile, skipping it ...", :yellow
        else
          say "Adding rails-erd gem", :green
          gem_content = <<~RUBY
            \n
            \tgem "rails-erd"
          RUBY
          insert_into_file "Gemfile", gem_content, after: /group :development do/
          bundle_install
        end
      end

      def configure_rails_erd_gem
        say 'Configuring rails-erd gem', :green

        Bundler.with_unbundled_env do
          run 'bundle exec rails g erd:install'
        end
      end
    end
  end
end
