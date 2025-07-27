class CreateCartItems < ActiveRecord::Migration[7.0]
  def change
    create_table :cart_items do |t|
      t.references :cart, null: false, foreign_key: true
      t.references :product, null: false, foreign_key: true
      t.string :variant_id, null: false
      t.integer :quantity, null: false, default: 1
      t.integer :unit_price_cents, null: false
      
      t.timestamps
    end
    
    add_index :cart_items, [:cart_id, :product_id, :variant_id], unique: true
    add_index :cart_items, :created_at
  end
end
