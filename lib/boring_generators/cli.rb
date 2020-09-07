# frozen_string_literal: true

require "thor"
require File.expand_path('lib/generators/boring/tailwind/install/install_generator', Dir.pwd)

module BoringGenerators
  class CLI < Thor
    desc "tailwind:install", "Adds Tailwind CSS to the application"
    def tailwind
      Boring::Tailwind::InstallGenerator.invoke
    end
  end
end
