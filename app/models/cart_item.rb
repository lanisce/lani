# Cart Item model for Medusa e-commerce integration
class CartItem < ApplicationRecord
  belongs_to :cart
  belongs_to :product
  
  validates :quantity, presence: true, numericality: { greater_than: 0 }
  validates :unit_price_cents, presence: true, numericality: { greater_than: 0 }
  validates :variant_id, presence: true
  
  def unit_price
    Money.new(unit_price_cents, cart.currency)
  end
  
  def unit_price=(amount)
    if amount.is_a?(Money)
      self.unit_price_cents = amount.cents
    else
      self.unit_price_cents = (amount.to_f * 100).to_i
    end
  end
  
  def total_cents
    quantity * unit_price_cents
  end
  
  def total
    Money.new(total_cents, cart.currency)
  end
  
  def formatted_unit_price
    unit_price.format
  end
  
  def formatted_total
    total.format
  end
  
  def variant_title
    variant = product.available_variants.find { |v| v['id'] == variant_id }
    variant ? variant['title'] : product.title
  end
end
