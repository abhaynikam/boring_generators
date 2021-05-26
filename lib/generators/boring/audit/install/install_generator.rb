# frozen_string_literal: true

module Boring
  module Audit
    class InstallGenerator < Rails::Generators::Base
      desc "Adds Audit gems to the application"

      def add_bullet_gem
        say "Adding audit gems", :green

        Bundler.with_unbundled_env do
          audit_gems_content = <<~RUBY
            \n
            \t# Patch-level verification for Bundler. https://github.com/rubysec/bundler-audit
            \tgem "bundler-audit", require: false
            \t# vulnerabity checker for Ruby itself. https://github.com/civisanalytics/ruby_audit
            \tgem "ruby_audit", require: false
          RUBY
          insert_into_file "Gemfile", audit_gems_content, after: /group :development do/
          run "bundle install"
        end
      end
    end
  end
end
