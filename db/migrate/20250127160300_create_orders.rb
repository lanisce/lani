class CreateOrders < ActiveRecord::Migration[7.0]
  def change
    create_table :orders do |t|
      t.string :medusa_id, null: false, index: { unique: true }
      t.references :user, null: false, foreign_key: true
      t.references :project, null: true, foreign_key: true
      t.integer :display_id, null: false
      t.string :status, null: false, default: 'pending'
      t.string :fulfillment_status, default: 'not_fulfilled'
      t.string :payment_status, default: 'not_paid'
      t.integer :total_cents, null: false, default: 0
      t.integer :subtotal_cents, default: 0
      t.integer :tax_total_cents, default: 0
      t.integer :shipping_total_cents, default: 0
      t.string :currency, null: false, default: 'usd'
      t.datetime :medusa_updated_at
      
      t.timestamps
    end
    
    add_index :orders, :status
    add_index :orders, :fulfillment_status
    add_index :orders, :payment_status
    add_index :orders, [:user_id, :project_id]
    add_index :orders, :display_id
    add_index :orders, :created_at
  end
end
