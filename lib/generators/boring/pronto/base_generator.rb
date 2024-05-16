# frozen_string_literal: true

require 'boring_generators/generator_helper'

module Boring
  module Pronto
    class BaseGenerator < Rails::Generators::Base
      desc "Adds Pronto gem with various extensions"

      class_option :extensions_to_skip,
       type: :array,
        aliases: "-se",
        desc: "Skip one or list of extensions. Example usage `--extensions_to_skip=rubocop flay`",
        enum: %w[brakeman flay reek rubocop],
        default: []

      include BoringGenerators::GeneratorHelper

      def add_pronto_gem
        say "Adding pronto gem", :green

        Bundler.with_unbundled_env do
          check_and_install_gem "pronto"
        end
      end

      def add_brakeman_extension
        return if options[:extensions_to_skip].include?('brakeman')

        say "Adding extension for brakeman", :green

        Bundler.with_unbundled_env do
          check_and_install_gem "pronto-brakeman", require: false
        end
      end

      def add_flay_extension
        return if options[:extensions_to_skip].include?('flay')

        say "Adding extension for flay", :green

        Bundler.with_unbundled_env do
          check_and_install_gem "pronto-flay", require: false
        end
      end

      def add_reek_extension
        return if options[:extensions_to_skip].include?('reek')

        say "Adding extension for reek", :green

        Bundler.with_unbundled_env do
          check_and_install_gem "pronto-reek", require: false
        end
      end

      def add_rubocop_extension
        return if options[:extensions_to_skip].include?('rubocop')

        say "Adding extension for rubocop", :green

        Bundler.with_unbundled_env do
          check_and_install_gem "pronto-rubocop", require: false
        end
      end
    end
  end
end
