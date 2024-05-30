# frozen_string_literal: true

require "generators/boring/pronto/base_generator"
require "boring_generators/generator_helper"

module Boring
  module Pronto
    module GithubAction
      class InstallGenerator < Boring::Pronto::BaseGenerator
        desc "Adds Pronto configurations to Github Action"
        source_root File.expand_path("templates", __dir__)

        class_option :ruby_version, type: :string, aliases: "-rv"

        include BoringGenerators::GeneratorHelper

        def add_pronto_configuration_for_github_action
          say "Adding Pronto configurations to .github/workflows/pronto.yml", :green

          @ruby_version = options.ruby_version || app_ruby_version
          
          template("pronto.yml", ".github/workflows/pronto.yml")
        end
      end
    end
  end
end
