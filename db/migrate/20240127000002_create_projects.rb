class CreateProjects < ActiveRecord::Migration[7.0]
  def change
    create_table :projects do |t|
      t.string :name, null: false
      t.text :description
      t.integer :status, default: 0, null: false
      t.references :owner, null: false, foreign_key: { to_table: :users }
      
      # Location fields for Mapbox integration
      t.decimal :latitude, precision: 10, scale: 6
      t.decimal :longitude, precision: 10, scale: 6
      t.string :location_name
      
      # Project metadata
      t.date :start_date
      t.date :end_date
      t.decimal :budget_limit, precision: 12, scale: 2
      
      t.timestamps
    end

    add_index :projects, :status
    add_index :projects, :owner_id
    add_index :projects, [:latitude, :longitude]
    add_index :projects, :name
  end
end
