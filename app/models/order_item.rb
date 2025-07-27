# Order Item model for Medusa e-commerce integration
class OrderItem < ApplicationRecord
  belongs_to :order
  belongs_to :product
  
  validates :quantity, presence: true, numericality: { greater_than: 0 }
  validates :unit_price_cents, presence: true, numericality: { greater_than: 0 }
  validates :total_cents, presence: true, numericality: { greater_than: 0 }
  validates :variant_id, presence: true
  
  def unit_price
    Money.new(unit_price_cents, order.currency)
  end
  
  def unit_price=(amount)
    if amount.is_a?(Money)
      self.unit_price_cents = amount.cents
    else
      self.unit_price_cents = (amount.to_f * 100).to_i
    end
  end
  
  def total
    Money.new(total_cents, order.currency)
  end
  
  def total=(amount)
    if amount.is_a?(Money)
      self.total_cents = amount.cents
    else
      self.total_cents = (amount.to_f * 100).to_i
    end
  end
  
  def formatted_unit_price
    unit_price.format
  end
  
  def formatted_total
    total.format
  end
  
  def variant_display_title
    variant_title.presence || product.title
  end
end
