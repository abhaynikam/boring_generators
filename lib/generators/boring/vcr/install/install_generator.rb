# frozen_string_literal: true

require 'boring_generators/generator_helper'

module Boring
  module Vcr
    class InstallGenerator < Rails::Generators::Base
      include BoringGenerators::GeneratorHelper
      
      desc "Adds VCR to the application"
      source_root File.expand_path("templates", __dir__)

      class_option :testing_framework,
                   type: :string,
                   alias: "-tf",
                   default: "minitest",
                   enum: %w[rspec minitest],
                   desc:
                     "Tell us which test framework you are using. Defaults to minitest"

      class_option :stubbing_libraries,
                   type: :array,
                   alias: "-sl",
                   default: ["webmock"],
                   enum: %w[webmock typhoeus faraday excon],
                   desc:
                     "Tell us stubbing library you want to use separated by space. Defaults to webmock"

      def verify_presence_of_test_helper
        return if rspec? || (minitest? && File.exist?("test/test_helper.rb"))

        say "We couldn't find test/test_helper.rb. Please configure Minitest and rerun the generator.",
            :red

        abort
      end

      def verify_presence_of_rails_helper
        return if minitest? || (rspec? && File.exist?("spec/rails_helper.rb"))

        say "We couldn't find spec/rails_helper.rb. Please configure RSpec and rerun the generator. Consider running `rails generate boring:rspec:install` to set up RSpec.",
            :red

        abort
      end

      def add_vcr_gem
        say "Adding VCR gems to Gemfile", :green
        
        check_and_install_gem "vcr", group: :test
      end

      def add_stubbing_library_gems
        say "Adding stubbing library gems to Gemfile", :green

        options[:stubbing_libraries].uniq.each do |stubbing_library|
          check_and_install_gem stubbing_library, group: :test
        end
      end

      def setup_vcr_for_rspec
        return unless rspec?

        say "Setting up VCR for RSpec", :green

        @stubbing_libraries = format_stubbing_libraries

        template("rspec/vcr.rb", "spec/support/vcr.rb")

        unless all_support_files_are_required?
          inject_into_file "spec/rails_helper.rb",
                           "require 'support/vcr'\n\n",
                           before: /\A/
        end
      end

      def setup_vcr_for_minitest
        return unless minitest?

        say "Setting up VCR for Minitest", :green

        vcr_config = <<~RUBY
          require "vcr"

          VCR.configure do |c|
            c.cassette_library_dir = "test/vcr"
            c.hook_into #{format_stubbing_libraries}
            c.ignore_localhost = true
          end
        RUBY

        inject_into_file "test/test_helper.rb", vcr_config, end: /^end\s*\Z/m
      end

      private

      def format_stubbing_libraries
        options[:stubbing_libraries]
          .map { |stubbing_library| ":#{stubbing_library}" }
          .join(", ")
      end

      def rspec?
        options[:testing_framework].to_s == "rspec"
      end

      def minitest?
        options[:testing_framework].to_s == "minitest"
      end

      def all_support_files_are_required?
        line_to_check =
          "Rails.root.glob('spec/support/**/*.rb').sort.each { |f| require f }"
        rails_file_content_array = File.readlines("spec/rails_helper.rb")
        rails_file_content_array.any? do |line|
          line !~ /^\s*#/ &&
            (
              line.include?(line_to_check) ||
                line.include?(line_to_check.gsub("'", '"'))
            )
        end
      end
    end
  end
end
