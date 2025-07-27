# Product model for Medusa e-commerce integration
class Product < ApplicationRecord
  belongs_to :project, optional: true
  has_many :cart_items, dependent: :destroy
  has_many :order_items, dependent: :destroy
  
  validates :title, presence: true
  validates :medusa_id, presence: true, uniqueness: true
  validates :price_cents, presence: true, numericality: { greater_than: 0 }
  validates :currency, presence: true
  
  scope :published, -> { where(status: 'published') }
  scope :by_collection, ->(collection) { where(collection_title: collection) }
  scope :search, ->(query) { where("title ILIKE ? OR description ILIKE ?", "%#{query}%", "%#{query}%") }
  
  def price
    Money.new(price_cents, currency)
  end
  
  def price=(amount)
    if amount.is_a?(Money)
      self.price_cents = amount.cents
      self.currency = amount.currency.to_s
    else
      self.price_cents = (amount.to_f * 100).to_i
    end
  end
  
  def formatted_price
    price.format
  end
  
  def in_stock?
    inventory_quantity > 0
  end
  
  def available_variants
    variants.present? ? variants : [default_variant]
  end
  
  def default_variant
    {
      'id' => "#{medusa_id}_default",
      'title' => title,
      'prices' => [{ 'amount' => price_cents, 'currency_code' => currency }],
      'inventory_quantity' => inventory_quantity
    }
  end
  
  def sync_from_medusa!(medusa_product)
    update!(
      title: medusa_product['title'],
      description: medusa_product['description'],
      price_cents: medusa_product.dig('variants', 0, 'prices', 0, 'amount') || 0,
      currency: medusa_product.dig('variants', 0, 'prices', 0, 'currency_code') || 'usd',
      inventory_quantity: medusa_product.dig('variants', 0, 'inventory_quantity') || 0,
      thumbnail_url: medusa_product['thumbnail'],
      images: medusa_product['images'] || [],
      variants: medusa_product['variants'] || [],
      collection_title: medusa_product.dig('collection', 'title'),
      tags: medusa_product['tags']&.map { |tag| tag['value'] } || [],
      status: medusa_product['status'] || 'draft',
      medusa_updated_at: medusa_product['updated_at']
    )
  end
  
  def self.sync_from_medusa
    medusa_client = ExternalApiService.medusa_client
    products_data = medusa_client.products
    
    products_data.each do |product_data|
      product = find_or_initialize_by(medusa_id: product_data['id'])
      product.sync_from_medusa!(product_data)
    end
    
    Rails.logger.info "Synced #{products_data.size} products from Medusa"
  end
end
