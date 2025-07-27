# frozen_string_literal: true

class PaymentsController < ApplicationController
  include PerformanceOptimized
  
  before_action :authenticate_user!
  before_action :set_order, only: [:create_payment_intent, :confirm_payment]
  skip_before_action :verify_authenticity_token, only: [:webhook]

  # Create payment intent for checkout
  def create_payment_intent
    authorize @order, :pay?
    
    begin
      customer_id = StripeService.create_or_get_customer(current_user)
      
      payment_intent = StripeService.create_payment_intent(
        amount: @order.total_amount,
        currency: 'usd',
        customer_id: customer_id,
        metadata: {
          order_id: @order.id,
          user_id: current_user.id,
          project_id: @order.project_id
        }
      )
      
      @order.update!(
        stripe_payment_intent_id: payment_intent.id,
        status: 'payment_pending'
      )
      
      render json: {
        client_secret: payment_intent.client_secret,
        publishable_key: StripeService.publishable_key
      }
    rescue StripeService::PaymentError => e
      render json: { error: e.message }, status: :unprocessable_entity
    end
  end

  # Confirm payment completion
  def confirm_payment
    authorize @order, :pay?
    
    payment_intent_id = params[:payment_intent_id]
    
    begin
      payment_intent = Stripe::PaymentIntent.retrieve(payment_intent_id)
      
      if payment_intent.status == 'succeeded'
        @order.update!(
          status: 'paid',
          paid_at: Time.current,
          payment_method: 'stripe'
        )
        
        # Process the order (fulfill items, send confirmations, etc.)
        OrderFulfillmentJob.perform_later(@order.id)
        
        render json: { 
          status: 'success', 
          message: 'Payment completed successfully',
          order_id: @order.id
        }
      else
        render json: { 
          status: 'error', 
          message: 'Payment not completed' 
        }, status: :unprocessable_entity
      end
    rescue Stripe::StripeError => e
      Rails.logger.error "Payment confirmation failed: #{e.message}"
      render json: { error: 'Payment confirmation failed' }, status: :unprocessable_entity
    end
  end

  # Create subscription for recurring payments
  def create_subscription
    authorize current_user, :subscribe?
    
    plan_id = params[:plan_id]
    price_id = subscription_plans[plan_id]&.dig(:stripe_price_id)
    
    unless price_id
      return render json: { error: 'Invalid plan selected' }, status: :unprocessable_entity
    end
    
    begin
      customer_id = StripeService.create_or_get_customer(current_user)
      
      subscription = StripeService.create_subscription(
        customer_id: customer_id,
        price_id: price_id,
        metadata: {
          user_id: current_user.id,
          plan_id: plan_id
        }
      )
      
      current_user.update!(
        subscription_plan: plan_id,
        stripe_subscription_id: subscription.id,
        subscription_status: subscription.status
      )
      
      render json: {
        subscription_id: subscription.id,
        client_secret: subscription.latest_invoice.payment_intent.client_secret,
        status: subscription.status
      }
    rescue StripeService::PaymentError => e
      render json: { error: e.message }, status: :unprocessable_entity
    end
  end

  # Cancel subscription
  def cancel_subscription
    authorize current_user, :manage_subscription?
    
    unless current_user.stripe_subscription_id
      return render json: { error: 'No active subscription found' }, status: :not_found
    end
    
    begin
      at_period_end = params[:at_period_end] != 'false'
      
      StripeService.cancel_subscription(
        current_user.stripe_subscription_id,
        at_period_end: at_period_end
      )
      
      status = at_period_end ? 'cancel_at_period_end' : 'cancelled'
      current_user.update!(subscription_status: status)
      
      render json: { 
        status: 'success', 
        message: 'Subscription cancelled successfully' 
      }
    rescue StripeService::PaymentError => e
      render json: { error: e.message }, status: :unprocessable_entity
    end
  end

  # Get customer portal URL for subscription management
  def customer_portal
    authorize current_user, :manage_subscription?
    
    unless current_user.stripe_customer_id
      return render json: { error: 'No customer account found' }, status: :not_found
    end
    
    begin
      return_url = request.referer || root_url
      
      portal_session = StripeService.create_customer_portal_session(
        current_user.stripe_customer_id,
        return_url
      )
      
      render json: { portal_url: portal_session.url }
    rescue StripeService::PaymentError => e
      render json: { error: e.message }, status: :unprocessable_entity
    end
  end

  # List user's payment methods
  def payment_methods
    authorize current_user, :manage_payment_methods?
    
    unless current_user.stripe_customer_id
      return render json: { payment_methods: [] }
    end
    
    begin
      payment_methods = StripeService.list_payment_methods(current_user.stripe_customer_id)
      
      formatted_methods = payment_methods.data.map do |pm|
        {
          id: pm.id,
          type: pm.type,
          card: pm.card ? {
            brand: pm.card.brand,
            last4: pm.card.last4,
            exp_month: pm.card.exp_month,
            exp_year: pm.card.exp_year
          } : nil,
          created: pm.created
        }
      end
      
      render json: { payment_methods: formatted_methods }
    rescue StripeService::PaymentError => e
      render json: { error: e.message }, status: :unprocessable_entity
    end
  end

  # Remove payment method
  def remove_payment_method
    authorize current_user, :manage_payment_methods?
    
    payment_method_id = params[:payment_method_id]
    
    begin
      StripeService.detach_payment_method(payment_method_id)
      render json: { status: 'success', message: 'Payment method removed' }
    rescue StripeService::PaymentError => e
      render json: { error: e.message }, status: :unprocessable_entity
    end
  end

  # Handle Stripe webhooks
  def webhook
    payload = request.body.read
    signature = request.env['HTTP_STRIPE_SIGNATURE']
    
    begin
      event = StripeService.handle_webhook(payload, signature)
      
      Rails.logger.info "Processed Stripe webhook: #{event.type}"
      render json: { status: 'success' }
    rescue StripeService::WebhookError => e
      Rails.logger.error "Webhook processing failed: #{e.message}"
      render json: { error: 'Webhook processing failed' }, status: :bad_request
    end
  end

  # Get subscription plans
  def plans
    render json: { plans: subscription_plans }
  end

  # Create refund
  def create_refund
    authorize current_user, :admin?
    
    order = Order.find(params[:order_id])
    amount = params[:amount]&.to_f
    reason = params[:reason]
    
    unless order.stripe_payment_intent_id
      return render json: { error: 'No payment found for this order' }, status: :not_found
    end
    
    begin
      refund = StripeService.create_refund(
        payment_intent_id: order.stripe_payment_intent_id,
        amount: amount,
        reason: reason
      )
      
      order.update!(
        status: amount ? 'partially_refunded' : 'refunded',
        refunded_at: Time.current,
        refund_amount: (order.refund_amount || 0) + (amount || order.total_amount)
      )
      
      render json: {
        status: 'success',
        refund_id: refund.id,
        amount: refund.amount / 100.0
      }
    rescue StripeService::PaymentError => e
      render json: { error: e.message }, status: :unprocessable_entity
    end
  end

  private

  def set_order
    @order = Order.find(params[:order_id] || params[:id])
  end

  def subscription_plans
    {
      'starter' => {
        name: 'Starter Plan',
        description: 'Perfect for small teams',
        price: 29.99,
        currency: 'usd',
        interval: 'month',
        stripe_price_id: ENV['STRIPE_STARTER_PRICE_ID'],
        features: [
          'Up to 5 projects',
          'Basic reporting',
          'Email support',
          '10GB storage'
        ]
      },
      'professional' => {
        name: 'Professional Plan',
        description: 'For growing businesses',
        price: 79.99,
        currency: 'usd',
        interval: 'month',
        stripe_price_id: ENV['STRIPE_PROFESSIONAL_PRICE_ID'],
        features: [
          'Unlimited projects',
          'Advanced reporting',
          'Priority support',
          '100GB storage',
          'API access',
          'Custom integrations'
        ]
      },
      'enterprise' => {
        name: 'Enterprise Plan',
        description: 'For large organizations',
        price: 199.99,
        currency: 'usd',
        interval: 'month',
        stripe_price_id: ENV['STRIPE_ENTERPRISE_PRICE_ID'],
        features: [
          'Everything in Professional',
          'Dedicated support',
          'Custom branding',
          'Unlimited storage',
          'Advanced security',
          'SLA guarantee'
        ]
      }
    }
  end
end
