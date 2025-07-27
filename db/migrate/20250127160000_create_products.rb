class CreateProducts < ActiveRecord::Migration[7.0]
  def change
    create_table :products do |t|
      t.string :medusa_id, null: false, index: { unique: true }
      t.string :title, null: false
      t.text :description
      t.integer :price_cents, null: false, default: 0
      t.string :currency, null: false, default: 'usd'
      t.integer :inventory_quantity, default: 0
      t.string :thumbnail_url
      t.json :images, default: []
      t.json :variants, default: []
      t.string :collection_title
      t.json :tags, default: []
      t.string :status, default: 'draft'
      t.datetime :medusa_updated_at
      t.references :project, null: true, foreign_key: true
      
      t.timestamps
    end
    
    add_index :products, :price_cents
    add_index :products, :status
    add_index :products, :collection_title
    add_index :products, :created_at
  end
end
