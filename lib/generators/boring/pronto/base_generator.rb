# frozen_string_literal: true

require "boring_generators/generator_helper"

module Boring
  module Pronto
    class BaseGenerator < Rails::Generators::Base
      desc "Adds Pronto gem with various extensions"

      class_option :skip_extensions,
                   type: :array,
                   aliases: "-se",
                   desc:
                     "List of extensions to skip. Available options: brakeman, flay, reek, rubocop",
                   enum: %w[brakeman flay reek rubocop],
                   default: []

      include BoringGenerators::GeneratorHelper

      def add_pronto_gems
        say "Adding pronto gems", :green

        gem_content = <<~RUBY.strip
          #{pronto_gem_content}
          #{pronto_brakemen_gem_content}
          #{pronto_flay_gem_content}
          #{pronto_reek_gem_content}
          #{pronto_rubocop_gem_content}
        RUBY

        return if gem_content.blank?

        insert_into_file "Gemfile", "\n#{gem_content}\n"

        Bundler.with_unbundled_env { run "bundle install" }
      end

      private

      def pronto_gem_content
        return if gem_installed?("pronto")

        <<~RUBY.strip
          # Pronto is a code linter runner that can be used with git and GitHub pull requests
          gem "pronto"
        RUBY
      end

      def pronto_brakemen_gem_content
        return if options[:skip_extensions].include?("brakeman")
        return if gem_installed?("pronto-brakeman")

        "gem \"pronto-brakeman\", require: false"
      end

      def pronto_flay_gem_content
        return if options[:skip_extensions].include?("flay")
        return if gem_installed?("pronto-flay")

        "gem \"pronto-flay\", require: false"
      end

      def pronto_reek_gem_content
        return if options[:skip_extensions].include?("reek")
        return if gem_installed?("pronto-reek")

        "gem \"pronto-reek\", require: false"
      end

      def pronto_rubocop_gem_content
        return if options[:skip_extensions].include?("rubocop")
        return if gem_installed?("pronto-rubocop")

        "gem \"pronto-rubocop\", require: false"
      end
    end
  end
end
