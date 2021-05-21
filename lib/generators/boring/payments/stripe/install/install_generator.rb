# frozen_string_literal: true

module Boring
  module Payments
    module Stripe
      class InstallGenerator < Rails::Generators::Base
        desc "Adds stripe payment method to the application"
        source_root File.expand_path("templates", __dir__)

        def add_stripe_gem
          say "Adding stripe gem", :green
          Bundler.with_unbundled_env do
            run "bundle add stripe"
          end
        end

        def add_checkouts_resources
          say "Adding stripe checkout resources"
          copy_file("controllers/stripe/checkouts_controller.rb", "app/controllers/stripe/checkouts_controller.rb")
          copy_file("views/stripe/checkouts/create.js.erb", "app/views/stripe/checkouts/create.js.erb")
          copy_file("views/stripe/checkouts/show.html.erb", "app/views/stripe/checkouts/show.html.erb")
        end

        def add_stripe_routes
          route <<~ROUTE
            namespace :stripe do
              resource :checkout, only: [:create, :show]
            end
          ROUTE
        end

        def add_stripe_initializer
          say "Adding stripe initalizers"
          copy_file("stripe.rb", "config/initializers/stripe.rb")
        end

        def show_readme
          readme "README"
        end
      end
    end
  end
end
