# frozen_string_literal: true
require "rails/generators"
require_relative "../boring_generators"

module BoringGenerators
  class CLI < Thor
    map "g" => :generate
    map %w(--version -v) => :__print_version

    desc "generate GENERATOR [options]", "Add gem to the application"
    def generate(generator, *options)
      Rails::Generators.invoke(generator, options)
    end

    desc "--version, -v", "Print gem version"
    def __print_version
      puts "Boring generators #{BoringGenerators::VERSION}"
    end

    class << self
      def exit_on_failure?
        true
      end
    end
  end
end
