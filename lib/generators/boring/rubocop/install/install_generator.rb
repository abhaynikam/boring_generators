# frozen_string_literal: true

module Boring
  module Rubocop
    class InstallGenerator < Rails::Generators::Base
      desc "Adds rubocop to the application"
      source_root File.expand_path("templates", __dir__)

      DEFAULT_RUBY_VERSION = "2.7.1"

      class_option :skip_adding_rubocop_rules, type: :boolean, aliases: "-s",
                                               desc: "Skip adding rubocop rules and add empty file."
      class_option :ruby_version,              type: :string, aliases: "-v",
                                               desc: "Tell us the ruby version which you use for the application. Default to Ruby #{DEFAULT_RUBY_VERSION}"

      def add_rubocop_gems
        say "Adding rubocop gems", :green
        rubocop_gem_content = <<~RUBY
          \n
          \t# A Ruby static code analyzer, based on the community Ruby style guide
          \tgem "rubocop",  require: false
          \tgem "rubocop-rails",  require: false
          \tgem "rubocop-performance", require: false
        RUBY
        insert_into_file "Gemfile", rubocop_gem_content, after: /group :development do/
        Bundler.with_unbundled_env do
          run "bundle install"
        end
      end

      def add_rails_prefered_rubocop_rules
        say "Adding rubocop style guides", :green
        @skip_adding_rules = options[:skip_adding_rubocop_rules]
        @target_ruby_version = options[:ruby_version] ? options[:ruby_version] : DEFAULT_RUBY_VERSION
        template(".rubocop.yml", ".rubocop.yml")
      end
    end
  end
end
