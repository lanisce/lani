class CreateOrderItems < ActiveRecord::Migration[7.0]
  def change
    create_table :order_items do |t|
      t.references :order, null: false, foreign_key: true
      t.references :product, null: false, foreign_key: true
      t.string :medusa_item_id
      t.string :variant_id, null: false
      t.string :variant_title
      t.integer :quantity, null: false, default: 1
      t.integer :unit_price_cents, null: false
      t.integer :total_cents, null: false
      
      t.timestamps
    end
    
    add_index :order_items, :medusa_item_id
    add_index :order_items, [:order_id, :product_id]
    add_index :order_items, :created_at
  end
end
