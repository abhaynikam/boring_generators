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
          say "Adding AWS gem", :green
          aws_gem_content = <<~RUBY
            \n
            # for AWS Service
            gem "aws-sdk-s3", require: false
          RUBY
          append_to_file "Gemfile", aws_gem_content
          run "bundle install"
        end

        def add_configuration_to_production
          gsub_file "config/environments/production.rb",
                    "config.active_storage.service = :local",
                    "config.active_storage.service = :amazon"
        end

        def uncomment_aws_storage_configuration
          uncomment_lines 'config/storage.yml', "amazon:"
          uncomment_lines 'config/storage.yml', "service: S3", verbose: false
          uncomment_lines 'config/storage.yml', "access_key_id:", verbose: false
          uncomment_lines 'config/storage.yml', 'secret_access_key: <%=', verbose: false
          uncomment_lines 'config/storage.yml', 'region:', verbose: false
          uncomment_lines 'config/storage.yml', "bucket", verbose: false
        end
      end
    end
  end
end
