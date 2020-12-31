# frozen_string_literal: true

module Boring
  module Rspec
    class InstallGenerator < Rails::Generators::Base
      desc "Adds rspec to the application"

      class_option :version, type: :string, aliases: "-v",
                             desc: "Tell us the gem version which you want to use for the application"

      def add_rspec_gem
        say "Adding rspec gem", :green
        rspec_gem_content = generate_gem_content
        append_to_file "Gemfile", rspec_gem_content
        run "bundle install"
      end

      def add_boilerplate_file
        say "Adding boilerplate file", :green
        run "rails generate rspec:install"
      end

      private

      def generate_gem_content
        rspec_rails_version= if options[:version].present?
                               ", \"~> #{options[:version]}\""
                             end
        <<~RUBY
          \n
          group :development, :test do
            gem "rspec-rails"#{rspec_rails_version}
          end
        RUBY
      end
    end
  end
end
