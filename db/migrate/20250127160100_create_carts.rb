class CreateCarts < ActiveRecord::Migration[7.0]
  def change
    create_table :carts do |t|
      t.string :medusa_id, null: false, index: { unique: true }
      t.references :user, null: false, foreign_key: true
      t.references :project, null: true, foreign_key: true
      t.string :currency, null: false, default: 'usd'
      t.string :status, default: 'active'
      t.integer :subtotal_cents, default: 0
      t.integer :tax_total_cents, default: 0
      t.integer :shipping_total_cents, default: 0
      t.integer :total_cents, default: 0
      t.datetime :completed_at
      
      t.timestamps
    end
    
    add_index :carts, :status
    add_index :carts, [:user_id, :project_id, :status]
    add_index :carts, :created_at
  end
end
