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

        def add_charges_controller
          say "Adding stripe charge resources"
          copy_file("controllers/charges_controller.rb", "app/controllers/charges_controller.rb")
        end

        def add_stripe_routes
          route "resources :charges"
        end

        def add_stripe_initializer
          say "Adding stripe initalizers"
          copy_file("stripe.rb", "config/initializers/stripe.rb")
        end

        def add_stripe_views
          say "Adding stripe views and layout"
          copy_file("views/charges.html.erb", "app/views/layouts/charges.html.erb")
          copy_file("views/new.html.erb", "app/views/charges/new.html.erb")
          copy_file("views/create.html.erb", "app/views/charges/create.html.erb")
        end

        def show_readme
          readme "README"
        end
      end
    end
  end
end
