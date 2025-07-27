# Cart model for Medusa e-commerce integration
class Cart < ApplicationRecord
  belongs_to :user
  belongs_to :project, optional: true
  has_many :cart_items, dependent: :destroy
  has_many :products, through: :cart_items
  
  validates :medusa_id, presence: true, uniqueness: true
  validates :currency, presence: true
  
  scope :active, -> { where(status: 'active') }
  scope :completed, -> { where(status: 'completed') }
  
  def total_cents
    cart_items.sum { |item| item.quantity * item.unit_price_cents }
  end
  
  def total
    Money.new(total_cents, currency)
  end
  
  def formatted_total
    total.format
  end
  
  def item_count
    cart_items.sum(:quantity)
  end
  
  def empty?
    cart_items.empty?
  end
  
  def add_product(product, quantity = 1, variant_id = nil)
    existing_item = cart_items.find_by(
      product: product, 
      variant_id: variant_id || product.medusa_id
    )
    
    if existing_item
      existing_item.update!(quantity: existing_item.quantity + quantity)
      existing_item
    else
      cart_items.create!(
        product: product,
        quantity: quantity,
        unit_price_cents: product.price_cents,
        variant_id: variant_id || product.medusa_id
      )
    end
  end
  
  def remove_product(product, variant_id = nil)
    cart_items.find_by(
      product: product, 
      variant_id: variant_id || product.medusa_id
    )&.destroy
  end
  
  def update_quantity(product, quantity, variant_id = nil)
    item = cart_items.find_by(
      product: product, 
      variant_id: variant_id || product.medusa_id
    )
    
    if item
      if quantity > 0
        item.update!(quantity: quantity)
      else
        item.destroy
      end
    end
  end
  
  def sync_to_medusa!
    medusa_client = ExternalApiService.medusa_client
    
    if medusa_id.blank?
      # Create new cart in Medusa
      medusa_cart = medusa_client.create_cart
      update!(medusa_id: medusa_cart['id'])
    end
    
    # Sync cart items to Medusa
    cart_items.each do |item|
      medusa_client.add_to_cart(
        medusa_id, 
        item.variant_id, 
        item.quantity
      )
    end
    
    # Update cart totals from Medusa response
    medusa_cart = medusa_client.get_cart(medusa_id)
    update!(
      subtotal_cents: medusa_cart['subtotal'] || 0,
      tax_total_cents: medusa_cart['tax_total'] || 0,
      shipping_total_cents: medusa_cart['shipping_total'] || 0,
      total_cents: medusa_cart['total'] || 0
    )
  end
  
  def complete_order!
    return nil if empty?
    
    sync_to_medusa!
    
    medusa_client = ExternalApiService.medusa_client
    medusa_order = medusa_client.create_order(medusa_id)
    
    # Create local order record
    order = Order.create!(
      user: user,
      project: project,
      medusa_id: medusa_order['id'],
      display_id: medusa_order['display_id'],
      status: medusa_order['status'],
      total_cents: medusa_order['total'],
      currency: medusa_order['currency_code']
    )
    
    # Create order items from cart items
    cart_items.each do |cart_item|
      order.order_items.create!(
        product: cart_item.product,
        quantity: cart_item.quantity,
        unit_price_cents: cart_item.unit_price_cents,
        variant_id: cart_item.variant_id
      )
    end
    
    # Mark cart as completed
    update!(status: 'completed', completed_at: Time.current)
    
    order
  end
  
  def self.current_for_user(user, project = nil)
    cart = active.find_by(user: user, project: project)
    
    unless cart
      # Create new cart via Medusa API
      medusa_client = ExternalApiService.medusa_client
      medusa_cart = medusa_client.create_cart
      
      cart = create!(
        user: user,
        project: project,
        medusa_id: medusa_cart['id'],
        currency: medusa_cart.dig('region', 'currency_code') || 'usd',
        status: 'active'
      )
    end
    
    cart
  end
end
