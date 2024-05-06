module Boring
  module ActiveStorage
    module Azure
      class InstallGenerator < Rails::Generators::Base
        desc "Adds ActiveStorage Microsoft Azure the application"

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
          Bundler.with_unbundled_env do
            azure_gem_content = <<~RUBY
              \n
              # for Azure Service
              gem "azure-storage-blob", require: false
            RUBY
            append_to_file "Gemfile", azure_gem_content
            run "bundle install"
          end
        end

        def add_configuration_to_production
          gsub_file "config/environments/production.rb",
                    "config.active_storage.service = :local",
                    "config.active_storage.service = :microsoft"
        end

        def add_azure_storage_configuration
          microsoft_storage_config_content = <<~RUBY
            microsoft:
              service: AzureStorage
              storage_account_name: your_account_name
              storage_access_key: <%= Rails.application.credentials.dig(:azure_storage, :storage_access_key) %>
              container: your_container_name
          RUBY

          append_to_file "config/storage.yml", microsoft_storage_config_content
        end
      end
    end
  end
end
