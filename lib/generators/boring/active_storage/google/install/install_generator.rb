module Boring
  module ActiveStorage
    module Google
      class InstallGenerator < Rails::Generators::Base
        desc "Adds ActiveStorage google cloud service the application"

        class_option :skip_active_storage, type: :boolean, aliases: "-s",
                                           desc: "Skips running ActiveStorage installer"

        def add_active_storage
          unless options[:skip_active_storage]
            say "Adding ActiveStorage", :green
            run "bin/rails active_storage:install"
          end
        end

        def add_google_cloud_storage_to_the_application
          say "Adding Bullet gem", :green
          google_cloud_storage_gem_content = <<~RUBY
            \n
            # for Google Cloud Storage Service
            gem "google-cloud-storage", "~> 1.28"
          RUBY
          append_to_file "Gemfile", google_cloud_storage_gem_content
          run "bundle install"
        end

        def add_configuration_to_production
          gsub_file "config/environments/production.rb",
                    "config.active_storage.service = :local",
                    "config.active_storage.service = :google"
        end

        def uncomment_google_storage_configuration
          uncomment_lines 'config/storage.yml', "google:"
          uncomment_lines 'config/storage.yml', "service: GCS", verbose: false
          uncomment_lines 'config/storage.yml', "project", verbose: false
          uncomment_lines 'config/storage.yml', 'credentials: <%=', verbose: false
          uncomment_lines 'config/storage.yml', "bucket", verbose: false
        end
      end
    end
  end
end
