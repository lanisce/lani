# frozen_string_literal: true

require 'stripe'

# StripeService handles all Stripe payment processing for the Lani platform
# Provides secure payment processing, subscription management, and webhook handling
class StripeService
  include Singleton

  # Initialize Stripe with API key
  def initialize
    Stripe.api_key = Rails.application.credentials.stripe&.secret_key || ENV['STRIPE_SECRET_KEY']
    @publishable_key = Rails.application.credentials.stripe&.publishable_key || ENV['STRIPE_PUBLISHABLE_KEY']
  end

  class << self
    delegate_missing_to :instance
  end

  # Get publishable key for frontend
  def publishable_key
    @publishable_key
  end

  # Create a payment intent for one-time payments
  def create_payment_intent(amount:, currency: 'usd', customer_id: nil, metadata: {})
    params = {
      amount: (amount * 100).to_i, # Convert to cents
      currency: currency,
      automatic_payment_methods: { enabled: true },
      metadata: metadata
    }
    
    params[:customer] = customer_id if customer_id
    
    Stripe::PaymentIntent.create(params)
  rescue Stripe::StripeError => e
    Rails.logger.error "Stripe payment intent creation failed: #{e.message}"
    raise PaymentError, e.message
  end

  # Create or retrieve a Stripe customer
  def create_or_get_customer(user)
    return user.stripe_customer_id if user.stripe_customer_id.present?

    customer = Stripe::Customer.create(
      email: user.email,
      name: user.name,
      metadata: {
        user_id: user.id,
        platform: 'lani'
      }
    )

    user.update!(stripe_customer_id: customer.id)
    customer.id
  rescue Stripe::StripeError => e
    Rails.logger.error "Stripe customer creation failed: #{e.message}"
    raise PaymentError, e.message
  end

  # Create a subscription for recurring payments
  def create_subscription(customer_id:, price_id:, metadata: {})
    Stripe::Subscription.create(
      customer: customer_id,
      items: [{ price: price_id }],
      payment_behavior: 'default_incomplete',
      payment_settings: { save_default_payment_method: 'on_subscription' },
      expand: ['latest_invoice.payment_intent'],
      metadata: metadata
    )
  rescue Stripe::StripeError => e
    Rails.logger.error "Stripe subscription creation failed: #{e.message}"
    raise PaymentError, e.message
  end

  # Cancel a subscription
  def cancel_subscription(subscription_id, at_period_end: true)
    subscription = Stripe::Subscription.retrieve(subscription_id)
    
    if at_period_end
      subscription.cancel_at_period_end = true
      subscription.save
    else
      subscription.cancel
    end
  rescue Stripe::StripeError => e
    Rails.logger.error "Stripe subscription cancellation failed: #{e.message}"
    raise PaymentError, e.message
  end

  # Create a setup intent for saving payment methods
  def create_setup_intent(customer_id:, metadata: {})
    Stripe::SetupIntent.create(
      customer: customer_id,
      payment_method_types: ['card'],
      usage: 'off_session',
      metadata: metadata
    )
  rescue Stripe::StripeError => e
    Rails.logger.error "Stripe setup intent creation failed: #{e.message}"
    raise PaymentError, e.message
  end

  # List customer's payment methods
  def list_payment_methods(customer_id, type: 'card')
    Stripe::PaymentMethod.list(
      customer: customer_id,
      type: type
    )
  rescue Stripe::StripeError => e
    Rails.logger.error "Stripe payment methods listing failed: #{e.message}"
    raise PaymentError, e.message
  end

  # Detach a payment method from customer
  def detach_payment_method(payment_method_id)
    payment_method = Stripe::PaymentMethod.retrieve(payment_method_id)
    payment_method.detach
  rescue Stripe::StripeError => e
    Rails.logger.error "Stripe payment method detachment failed: #{e.message}"
    raise PaymentError, e.message
  end

  # Create a refund
  def create_refund(payment_intent_id:, amount: nil, reason: nil)
    params = { payment_intent: payment_intent_id }
    params[:amount] = (amount * 100).to_i if amount # Convert to cents
    params[:reason] = reason if reason

    Stripe::Refund.create(params)
  rescue Stripe::StripeError => e
    Rails.logger.error "Stripe refund creation failed: #{e.message}"
    raise PaymentError, e.message
  end

  # Handle webhook events
  def handle_webhook(payload, signature)
    endpoint_secret = Rails.application.credentials.stripe&.webhook_secret || ENV['STRIPE_WEBHOOK_SECRET']
    
    event = Stripe::Webhook.construct_event(payload, signature, endpoint_secret)
    
    case event.type
    when 'payment_intent.succeeded'
      handle_payment_success(event.data.object)
    when 'payment_intent.payment_failed'
      handle_payment_failure(event.data.object)
    when 'customer.subscription.created'
      handle_subscription_created(event.data.object)
    when 'customer.subscription.updated'
      handle_subscription_updated(event.data.object)
    when 'customer.subscription.deleted'
      handle_subscription_deleted(event.data.object)
    when 'invoice.payment_succeeded'
      handle_invoice_payment_success(event.data.object)
    when 'invoice.payment_failed'
      handle_invoice_payment_failure(event.data.object)
    else
      Rails.logger.info "Unhandled Stripe webhook event: #{event.type}"
    end

    event
  rescue Stripe::SignatureVerificationError => e
    Rails.logger.error "Stripe webhook signature verification failed: #{e.message}"
    raise WebhookError, 'Invalid signature'
  rescue Stripe::StripeError => e
    Rails.logger.error "Stripe webhook processing failed: #{e.message}"
    raise WebhookError, e.message
  end

  # Get subscription details
  def get_subscription(subscription_id)
    Stripe::Subscription.retrieve(subscription_id)
  rescue Stripe::StripeError => e
    Rails.logger.error "Stripe subscription retrieval failed: #{e.message}"
    raise PaymentError, e.message
  end

  # Update subscription
  def update_subscription(subscription_id, params)
    subscription = Stripe::Subscription.retrieve(subscription_id)
    subscription.update(params)
  rescue Stripe::StripeError => e
    Rails.logger.error "Stripe subscription update failed: #{e.message}"
    raise PaymentError, e.message
  end

  # Create a product
  def create_product(name:, description: nil, metadata: {})
    Stripe::Product.create(
      name: name,
      description: description,
      metadata: metadata
    )
  rescue Stripe::StripeError => e
    Rails.logger.error "Stripe product creation failed: #{e.message}"
    raise PaymentError, e.message
  end

  # Create a price for a product
  def create_price(product_id:, amount:, currency: 'usd', recurring: nil)
    params = {
      product: product_id,
      unit_amount: (amount * 100).to_i, # Convert to cents
      currency: currency
    }
    
    params[:recurring] = recurring if recurring
    
    Stripe::Price.create(params)
  rescue Stripe::StripeError => e
    Rails.logger.error "Stripe price creation failed: #{e.message}"
    raise PaymentError, e.message
  end

  # Get customer portal URL
  def create_customer_portal_session(customer_id, return_url)
    Stripe::BillingPortal::Session.create(
      customer: customer_id,
      return_url: return_url
    )
  rescue Stripe::StripeError => e
    Rails.logger.error "Stripe customer portal creation failed: #{e.message}"
    raise PaymentError, e.message
  end

  private

  def handle_payment_success(payment_intent)
    Rails.logger.info "Payment succeeded: #{payment_intent.id}"
    
    # Find related order or transaction
    if payment_intent.metadata['order_id']
      order = Order.find_by(id: payment_intent.metadata['order_id'])
      order&.update!(
        status: 'paid',
        stripe_payment_intent_id: payment_intent.id,
        paid_at: Time.current
      )
    end
    
    # Send confirmation email
    PaymentConfirmationJob.perform_later(payment_intent.id)
  end

  def handle_payment_failure(payment_intent)
    Rails.logger.error "Payment failed: #{payment_intent.id}"
    
    # Find related order or transaction
    if payment_intent.metadata['order_id']
      order = Order.find_by(id: payment_intent.metadata['order_id'])
      order&.update!(
        status: 'payment_failed',
        stripe_payment_intent_id: payment_intent.id
      )
    end
    
    # Send failure notification
    PaymentFailureJob.perform_later(payment_intent.id)
  end

  def handle_subscription_created(subscription)
    Rails.logger.info "Subscription created: #{subscription.id}"
    
    # Update user subscription status
    customer_id = subscription.customer
    user = User.find_by(stripe_customer_id: customer_id)
    
    if user
      user.update!(
        subscription_status: 'active',
        stripe_subscription_id: subscription.id,
        subscription_started_at: Time.current
      )
    end
  end

  def handle_subscription_updated(subscription)
    Rails.logger.info "Subscription updated: #{subscription.id}"
    
    # Update user subscription status
    user = User.find_by(stripe_subscription_id: subscription.id)
    
    if user
      user.update!(
        subscription_status: subscription.status,
        subscription_updated_at: Time.current
      )
    end
  end

  def handle_subscription_deleted(subscription)
    Rails.logger.info "Subscription deleted: #{subscription.id}"
    
    # Update user subscription status
    user = User.find_by(stripe_subscription_id: subscription.id)
    
    if user
      user.update!(
        subscription_status: 'cancelled',
        subscription_ended_at: Time.current
      )
    end
  end

  def handle_invoice_payment_success(invoice)
    Rails.logger.info "Invoice payment succeeded: #{invoice.id}"
    
    # Handle successful recurring payment
    subscription_id = invoice.subscription
    user = User.find_by(stripe_subscription_id: subscription_id)
    
    if user
      user.update!(last_payment_at: Time.current)
    end
  end

  def handle_invoice_payment_failure(invoice)
    Rails.logger.error "Invoice payment failed: #{invoice.id}"
    
    # Handle failed recurring payment
    subscription_id = invoice.subscription
    user = User.find_by(stripe_subscription_id: subscription_id)
    
    if user
      PaymentFailureNotificationJob.perform_later(user.id, invoice.id)
    end
  end

  # Custom error classes
  class PaymentError < StandardError; end
  class WebhookError < StandardError; end
end
