module Boring
  module ActiveStorage
    module Azure
      class InstallGenerator < Rails::Generators::Base
        desc "Adds ActiveStorage Mircosoft Azure the application"

        class_option :skip_active_storage, type: :boolean, aliases: "-s",
                                           desc: "Skips running ActiveStorage installer"

        def add_active_storage
          unless options[:skip_active_storage]
            say "Adding ActiveStorage", :green
            run "bin/rails active_storage:install"
          end
        end

        def add_azure_to_the_application
          say "Adding mircosoft azure gem", :green
          azure_gem_content = <<~RUBY
            \n
            # for Azure Service
            gem "azure-storage-blob", require: false
          RUBY
          append_to_file "Gemfile", azure_gem_content
          run "bundle install"
        end

        def add_configuration_to_production
          gsub_file "config/environments/production.rb",
                    "config.active_storage.service = :local",
                    "config.active_storage.service = :microsoft"
        end

        def uncomment_azure_storage_configuration
          uncomment_lines 'config/storage.yml', "microsoft:"
          uncomment_lines 'config/storage.yml', "service: AzureStorage", verbose: false
          uncomment_lines 'config/storage.yml', "storage_account_name:", verbose: false
          uncomment_lines 'config/storage.yml', 'storage_access_key:', verbose: false
          uncomment_lines 'config/storage.yml', "container:", verbose: false
        end
      end
    end
  end
end
