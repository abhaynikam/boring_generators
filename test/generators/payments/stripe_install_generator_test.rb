# frozen_string_literal: true

require "test_helper"
require "generators/boring/payments/stripe/install/install_generator"

class StripeInstallGeneratorTest < Rails::Generators::TestCase
  tests Boring::Payments::Stripe::InstallGenerator
  setup :build_app
  teardown :teardown_app

  include GeneratorHelper
  include ActiveSupport::Testing::Isolation

  def destination_root
    app_path
  end

  def test_should_install_stripe_gem_successfully
    Dir.chdir(app_path) do
      quietly { run_generator }

      assert_gem "stripe"
      assert_file "config/initializers/stripe.rb"
      assert_file "app/views/layouts/charges.html.erb"
      assert_file "app/views/charges/new.html.erb"
      assert_file "app/views/charges/create.html.erb"
    end
  end
end
