# frozen_string_literal: true

module Boring
  module Brakeman
    class InstallGenerator < Rails::Generators::Base
      desc 'Adds Brakeman to the application'
      source_root File.expand_path('templates', __dir__)

      RUBY_VERSION_FILE = '.ruby-version'

      DEFAULT_RUBY_VERSION = '.ruby-version'

      class_option :skip_config, type: :boolean, aliases: '-c',
                                                desc: 'Skip adding Brakeman configuration'

      class_option :skip_github, type: :boolean, aliases: '-gh',
                                                desc: 'Skip adding GitHub Actions configuration'

      class_option :skip_gitlab, type: :boolean, aliases: '-gl',
                                                desc: 'Skip adding GitLab CI configuration'

      class_option :ruby_version, type: :string, aliases: '-v',
                                                 desc: "Tell us the ruby version which you use for the application. Default to Ruby #{DEFAULT_RUBY_VERSION}, which will cause the action to use the version specified in the #{RUBY_VERSION_FILE} file."

      def add_brakeman_gem
        say 'Adding Brakeman gem', :green

        gem_content = <<~RUBY
          \t# A static analysis security vulnerability scanner for Ruby on Rails applications
          \tgem 'brakeman', require: false
        RUBY

        insert_into_file 'Gemfile', gem_content, after: /group :development do/

        Bundler.with_unbundled_env do
          run 'bundle install'
        end
      end

      def configure_brakeman
        return if options[:skip_config]

        say 'Copying Brakeman configuration', :green

        template 'brakeman.yml', 'config/brakeman.yml'
      end

      def configure_github_actions_for_brakeman
        return if options[:skip_github]

        @ruby_version = options[:ruby_version] ? options[:ruby_version] : DEFAULT_RUBY_VERSION

        say 'Copying GitHub Actions configuration', :green

        empty_directory 'github/.workflows'
        template 'github/ci.yml', '.github/workflows/ci.yml'
      end

      def configure_gitlab_ci_for_brakeman
        return if options[:skip_gitlab]

        @ruby_version = options[:ruby_version] ? options[:ruby_version] : DEFAULT_RUBY_VERSION

        say 'Copying GitLab CI configuration', :green

        template 'gitlab/ci.yml', '.gitlab-ci.yml'
      end
    end
  end
end
