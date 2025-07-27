# Order model for Medusa e-commerce integration
class Order < ApplicationRecord
  belongs_to :user
  belongs_to :project, optional: true
  has_many :order_items, dependent: :destroy
  has_many :products, through: :order_items
  
  validates :medusa_id, presence: true, uniqueness: true
  validates :display_id, presence: true
  validates :status, presence: true
  validates :total_cents, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :currency, presence: true
  
  enum status: {
    pending: 'pending',
    completed: 'completed',
    archived: 'archived',
    canceled: 'canceled',
    requires_action: 'requires_action'
  }
  
  enum fulfillment_status: {
    not_fulfilled: 'not_fulfilled',
    partially_fulfilled: 'partially_fulfilled',
    fulfilled: 'fulfilled',
    partially_shipped: 'partially_shipped',
    shipped: 'shipped',
    partially_returned: 'partially_returned',
    returned: 'returned',
    canceled: 'canceled',
    requires_action: 'requires_action'
  }, _prefix: :fulfillment
  
  enum payment_status: {
    not_paid: 'not_paid',
    awaiting: 'awaiting',
    captured: 'captured',
    partially_refunded: 'partially_refunded',
    refunded: 'refunded',
    canceled: 'canceled',
    requires_action: 'requires_action'
  }, _prefix: :payment
  
  scope :recent, -> { order(created_at: :desc) }
  scope :by_status, ->(status) { where(status: status) }
  scope :for_project, ->(project) { where(project: project) }
  
  def total
    Money.new(total_cents, currency)
  end
  
  def total=(amount)
    if amount.is_a?(Money)
      self.total_cents = amount.cents
      self.currency = amount.currency.to_s
    else
      self.total_cents = (amount.to_f * 100).to_i
    end
  end
  
  def formatted_total
    total.format
  end
  
  def subtotal
    Money.new(subtotal_cents || 0, currency)
  end
  
  def formatted_subtotal
    subtotal.format
  end
  
  def tax_total
    Money.new(tax_total_cents || 0, currency)
  end
  
  def formatted_tax_total
    tax_total.format
  end
  
  def shipping_total
    Money.new(shipping_total_cents || 0, currency)
  end
  
  def formatted_shipping_total
    shipping_total.format
  end
  
  def item_count
    order_items.sum(:quantity)
  end
  
  def can_be_canceled?
    pending? && payment_not_paid?
  end
  
  def can_be_refunded?
    completed? && payment_captured?
  end
  
  def sync_from_medusa!(medusa_order)
    update!(
      display_id: medusa_order['display_id'],
      status: medusa_order['status'],
      fulfillment_status: medusa_order['fulfillment_status'],
      payment_status: medusa_order['payment_status'],
      total_cents: medusa_order['total'],
      subtotal_cents: medusa_order['subtotal'],
      tax_total_cents: medusa_order['tax_total'],
      shipping_total_cents: medusa_order['shipping_total'],
      currency: medusa_order['currency_code'],
      medusa_updated_at: medusa_order['updated_at']
    )
    
    # Sync order items
    if medusa_order['items'].present?
      medusa_order['items'].each do |item_data|
        item = order_items.find_or_initialize_by(medusa_item_id: item_data['id'])
        
        # Find or create product
        product = Product.find_by(medusa_id: item_data['variant']['product_id']) ||
                 Product.create!(
                   medusa_id: item_data['variant']['product_id'],
                   title: item_data['title'],
                   price_cents: item_data['unit_price'],
                   currency: currency
                 )
        
        item.update!(
          product: product,
          quantity: item_data['quantity'],
          unit_price_cents: item_data['unit_price'],
          total_cents: item_data['total'],
          variant_id: item_data['variant_id'],
          variant_title: item_data.dig('variant', 'title')
        )
      end
    end
  end
  
  def self.sync_from_medusa(user = nil)
    medusa_client = ExternalApiService.medusa_client
    orders_data = medusa_client.orders(user&.medusa_customer_id)
    
    orders_data.each do |order_data|
      # Find user if not provided
      unless user
        # This would require customer data from Medusa
        # For now, we'll skip orders without a user
        next
      end
      
      order = find_or_initialize_by(medusa_id: order_data['id'])
      order.user = user
      order.sync_from_medusa!(order_data)
    end
    
    Rails.logger.info "Synced #{orders_data.size} orders from Medusa"
  end
  
  def cancel!
    return false unless can_be_canceled?
    
    # Cancel in Medusa (would need API endpoint)
    # medusa_client = ExternalApiService.medusa_client
    # medusa_client.cancel_order(medusa_id)
    
    update!(status: 'canceled')
  end
  
  def request_refund!(reason = nil)
    return false unless can_be_refunded?
    
    # Request refund in Medusa (would need API endpoint)
    # medusa_client = ExternalApiService.medusa_client
    # medusa_client.refund_order(medusa_id, reason: reason)
    
    update!(payment_status: 'partially_refunded')
  end
end
