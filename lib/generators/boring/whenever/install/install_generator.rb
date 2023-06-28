# frozen_string_literal: true

module Boring
  module Whenever
    class InstallGenerator < Rails::Generators::Base
      desc "Adds whenever gem to the application for managing cron jobs"

      def add_whenever_gem
        say "Adding whenever gem", :green

        Bundler.with_unbundled_env do
          run "bundle add whenever"
        end
      end

      def add_schedule_file
          say "Create schedule.rb file", :green

          Bundler.with_unbundled_env do
            run "bundle exec wheneverize ."
          end
      end
    end
  end
end
