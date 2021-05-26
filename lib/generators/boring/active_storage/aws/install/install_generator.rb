module Boring
  module ActiveStorage
    module Aws
      class InstallGenerator < Rails::Generators::Base
        desc "Adds ActiveStorage AWS service the application"

        class_option :skip_active_storage, type: :boolean, aliases: "-s",
                                           desc: "Skips running ActiveStorage installer"

        def add_active_storage
          unless options[:skip_active_storage]
            say "Adding ActiveStorage", :green
            run "bin/rails active_storage:install"
          end
        end

        def add_aws_to_the_application
          Bundler.with_unbundled_env do
            say "Adding AWS gem", :green
            aws_gem_content = <<~RUBY
              \n
              # for AWS Service
              gem "aws-sdk-s3", require: false
            RUBY
            append_to_file "Gemfile", aws_gem_content
            run "bundle install"
          end
        end

        def add_configuration_to_production
          gsub_file "config/environments/production.rb",
                    "config.active_storage.service = :local",
                    "config.active_storage.service = :amazon"
        end

        def add_aws_storage_configuration
          aws_storage_config_content = <<~RUBY
            amazon:
              service: S3
              access_key_id: <%= Rails.application.credentials.dig(:aws, :access_key_id) %>
              secret_access_key: <%= Rails.application.credentials.dig(:aws, :secret_access_key) %>
              region: us-east-1
              bucket: your_own_bucket
          RUBY
          append_to_file "config/storage.yml", aws_storage_config_content
        end
      end
    end
  end
end
