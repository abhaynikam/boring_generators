# frozen_string_literal: true

require 'boring_generators/generator_helper'

module Boring
  module Webmock
    class InstallGenerator < Rails::Generators::Base
      include BoringGenerators::GeneratorHelper
      
      desc "Adds webmock gem to the application"

      SUPPORTED_TEST_FRAMEWORKS = %w[rspec minitest]

      # can't use "test_framework" option which would be a good naming for this because it's being used by Rails::Generator::Base. Rails will override this value if we use test_framework so prefixing with "app_" here
      class_option :app_test_framework,
                   type: :string,
                   desc: "Tell us the framework you use for writing tests in your application. Supported options are #{SUPPORTED_TEST_FRAMEWORKS}",
                   default: "minitest"

      def verify_test_framework_configurations
        app_test_framework = options[:app_test_framework]

        if app_test_framework.blank?
          say <<~WARNING, :red
           ERROR: Unsupported test framework: #{app_test_framework}
          WARNING

          abort
        else
          verify_presence_of_test_framework
        end
      end

      def add_webmock_gem
        say "Adding webmock gem", :green

        check_and_install_gem "webmock", group: :test
      end

      def configure_webmock
        app_test_framework = options[:app_test_framework]

        say "Configuring webmock", :green

        if app_test_framework == "minitest"
          configure_minitest
        else
          configure_rspec
        end
      end

      private

      def verify_presence_of_test_framework
        app_test_framework = options[:app_test_framework]
        test_framework_folder = { minitest: "test", rspec: "spec" }.dig(app_test_framework.to_sym) || ''

        test_folder_is_present = Dir.exist?(test_framework_folder) && Dir.entries(test_framework_folder).length.positive?

        return if test_folder_is_present

        say "We couldn't find #{test_framework_folder} in your project. Please make sure #{app_test_framework} is configured correctly and run the generator again!", :red

        abort
      end

      def configure_minitest
        inject_into_file 'test/test_helper.rb',
                          before: /\n(class|module) ActiveSupport/ do
                            <<~RUBY
                              \nrequire 'webmock/minitest'
                              WebMock.disable_net_connect!(allow_localhost: true)
                            RUBY
                          end
      end

      def configure_rspec
        inject_into_file "spec/spec_helper.rb",
                          "require 'webmock/rspec'\n\n",
                          before: /\A/
        inject_into_file "spec/spec_helper.rb",
                          "\tWebMock.disable_net_connect!(allow_localhost: true)\n\n",
                          after: "RSpec.configure do |config|\n"
      end
    end
  end
end
