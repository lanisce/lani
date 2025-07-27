class CreateBudgets < ActiveRecord::Migration[7.0]
  def change
    create_table :budgets do |t|
      t.references :project, null: false, foreign_key: true
      t.string :name, null: false
      t.text :description
      t.decimal :amount, precision: 10, scale: 2, null: false
      t.string :category, null: false
      t.date :period_start, null: false
      t.date :period_end, null: false
      t.boolean :active, default: true

      t.timestamps
    end

    add_index :budgets, [:project_id, :category]
    add_index :budgets, [:period_start, :period_end]
    add_index :budgets, :active
  end
end
