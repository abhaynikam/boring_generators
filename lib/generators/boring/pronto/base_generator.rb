# frozen_string_literal: true

require 'boring_generators/generator_helper'

module Boring
  module Pronto
    class BaseGenerator < Rails::Generators::Base
      desc "Adds Pronto gem with various extensions"

      class_option :skip_extensions, type: :array, aliases: "-se",
                   desc: "List of extensions to skip. Available options: brakeman, flay, reek, rubocop",
                   enum: %w[brakeman flay reek rubocop],
                   default: []

      include BoringGenerators::GeneratorHelper

      def add_pronto_gems
        say "Adding pronto gems", :green
        pronto_gem_content = <<~RUBY
          \n
          \t# Pronto is a code linter runner that can be used with git and GitHub pull requests
          \tgem "pronto"
          #{pronto_brakemen_gem_content}
          #{pronto_flay_gem_content}
        RUBY
        insert_into_file "Gemfile", pronto_gem_content
        Bundler.with_unbundled_env do
          run "bundle install"
        end
      end

      def pronto_brakemen_gem_content
        return unless options[:skip_extensions].exclude?('brakeman')
        return if gem_installed?('pronto-brakeman')

        "\tgem \"pronto-brakeman\", require: false"
      end

      def pronto_flay_gem_content
        return unless options[:skip_extensions].exclude?('flay')
        return if gem_installed?('pronto-flay')

        "\tgem \"pronto-flay\", require: false"
      end
    end
  end
end
