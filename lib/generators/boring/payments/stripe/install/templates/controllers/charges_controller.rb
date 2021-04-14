# frozen_string_literal: true

class ChargesController < ApplicationController
  def new
    render
  end

  def create
    if create_stripe_customer && create_stripe_charge
      redirect_to root_path, flash: { success: "Boring stripe setup is successful" }
    else
      redirect_to new_charge_path, flash: { error: "Ugh. Something went wrong in setup." }
    end
  rescue Stripe::CardError => e
    flash[:error] = e.message
    redirect_to new_charge_path
  end

  private
    def create_stripe_customer
      @customer = Stripe::Customer.create({
        email: params[:stripeEmail],
        source: params[:stripeToken],
      })
    end

    def create_stripe_charge
      # Amount in cents
      @amount = 500

      Stripe::Charge.create({
        customer: customer.id,
        amount: @amount,
        description: 'Rails Stripe customer',
        currency: 'usd',
      })
    end
end
