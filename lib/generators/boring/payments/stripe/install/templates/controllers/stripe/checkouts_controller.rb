# frozen_string_literal: true

class Stripe::CheckoutsController < ApplicationController
  def create
    begin
      @stripe_session = Stripe::Checkout::Session.create(checkout_payload)

      respond_to :js
    rescue Stripe::CardError => e
      puts "Status is: #{e.http_status}"
      puts "Type is: #{e.error.type}"
      puts "Charge ID is: #{e.error.charge}"
      # The following fields are optional
      puts "Code is: #{e.error.code}" if e.error.code
      puts "Decline code is: #{e.error.decline_code}" if e.error.decline_code
      puts "Param is: #{e.error.param}" if e.error.param
      puts "Message is: #{e.error.message}" if e.error.message
    rescue Stripe::RateLimitError => e
      # Too many requests made to the API too quickly
    rescue Stripe::InvalidRequestError => e
      # Invalid parameters were supplied to Stripe's API
    rescue Stripe::AuthenticationError => e
      # Authentication with Stripe's API failed
      # (maybe you changed API keys recently)
    rescue Stripe::APIConnectionError => e
      # Network communication with Stripe failed
    rescue Stripe::StripeError => e
      # Display a very generic error to the user, and maybe send
      # yourself an email
    rescue => e
      # Something else happened, completely unrelated to Stripe
    end
  end

  def show
    render
  end

  private
    # In the payload, the line items consists of list of items the customer is purchasing.
    # Refer the guides to learn more about parameters accepted by the <line_items>
    # https://stripe.com/docs/api/checkout/sessions/create#create_checkout_session-line_items
    #
    # Sample: <line_items> looks like as follows:
    # line_items: [{
    #   price_data: {
    #     currency: 'usd',                      # Three-letter ISO currency code, in lowercase
    #     product: <product_id>                 # Product ID created on stripe.
    #     product_data: { name: 'T-shirt' },    # Product Data (Either product_data or product is requried).
    #     unit_amount: 2000,                    # A non-negative integer in cents representing how much to charge
    #   },
    #   quantity: 1,
    # }]
    def checkout_payload
      {
        payment_method_types: ['card'],  # https://stripe.com/docs/api/payment_methods/object#payment_method_object-type
        line_items: @line_items || [],
        mode: 'payment',
        success_url: root_url,           # <custom_success_path>
        cancel_url: root_url,            # <custom_cancellation_path>
      }
    end
end
