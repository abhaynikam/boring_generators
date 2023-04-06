# frozen_string_literal: true

module Boring
  module LetterOpener
    class InstallGenerator < Rails::Generators::Base
      desc "Adds Letter Opener gem to the application for previewing email in the default browser instead of sending it"

      def add_letter_opener_gem
        say "Adding letter_opener gem", :green

        gem_content = <<~RUBY
          \t# Preview email in the default browser instead of sending it to real mailbox
          \tgem "letter_opener"
        RUBY

        insert_into_file "Gemfile", gem_content, after: /group :development do/

        Bundler.with_unbundled_env do
          run "bundle install"
        end
      end

      def configure_letter_opener
        say "Configuring letter_opener", :green

        configuration_content = <<~RUBY.chomp
          \n
          \tconfig.action_mailer.delivery_method = :letter_opener
          \tconfig.action_mailer.perform_deliveries = true
        RUBY

        insert_into_file "config/environments/development.rb",
                         configuration_content,
                         after: /config.action_mailer.perform_caching = (true|false)/
      end
    end
  end
end
