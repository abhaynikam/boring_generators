# frozen_string_literal: true

module Boring
  module Figjam
    class InstallGenerator < Rails::Generators::Base
      desc 'Adds figjam gem to the app'

      def add_figjam_gem
        say 'Adding figjam gem', :green

        Bundler.with_unbundled_env do
          run 'bundle add figjam'
        end
      end

      def configure_figjam
        say 'Configuring figjam', :green

        Bundler.with_unbundled_env do
          run 'bundle exec figjam install'
        end

        FileUtils.cp('config/application.yml', 'config/application.yml.sample')

        unless File.exist?('.gitignore')
          create_file '.gitignore'
        end

        insert_into_file('.gitignore', "\n/config/application.yml\n")
      end
    end
  end
end
