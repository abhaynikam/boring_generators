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
          say "Adding google cloud storage gem", :green
          Bundler.with_unbundled_env do
            google_cloud_storage_gem_content = <<~RUBY
              \n
              # for Google Cloud Storage Service
              gem "google-cloud-storage", require: false
            RUBY
            append_to_file "Gemfile", google_cloud_storage_gem_content
            run "bundle install"
          end
        end

        def add_configuration_to_production
          gsub_file "config/environments/production.rb",
                    "config.active_storage.service = :local",
                    "config.active_storage.service = :google"
        end

        def add_google_storage_configuration
          google_storage_config_content = <<~RUBY
            google:
              service: GCS
              project: your_project
              credentials: <%= Rails.root.join("path/to/gcs.keyfile") %>
              bucket: your_own_bucket
          RUBY

          append_to_file "config/storage.yml", google_storage_config_content
        end
      end
    end
  end
end
