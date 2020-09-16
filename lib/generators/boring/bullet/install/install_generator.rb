# frozen_string_literal: true

module Boring
  module Bullet
    class InstallGenerator < Rails::Generators::Base
      desc "Adds Bullet gem to the application"
      source_root File.expand_path("templates", __dir__)

      class_option :skip_configuration, type: :boolean, aliases: "-s",
                                        desc: "Skips adding bullet development configuration"

      def add_bullet_gem
        say "Adding font_awesome_sass gem", :green
        bullet_gem_content = <<~RUBY
          \n
          \t# reports N+1 queries
          \tgem "bullet"
        RUBY
        insert_into_file "Gemfile", bullet_gem_content, after: /group :development do/
        run "bundle install"
      end

      def add_bullet_gem_configuration
        return if options[:skip_configuration]

        say "Copying bullet.rb configuration to the initializer", :green
        template("bullet.rb", "config/initializers/bullet.rb")
      end
    end
  end
end
