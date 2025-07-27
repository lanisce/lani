class CreateTransactions < ActiveRecord::Migration[7.0]
  def change
    create_table :transactions do |t|
      t.references :project, null: false, foreign_key: true
      t.references :budget, null: true, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.string :description, null: false
      t.decimal :amount, precision: 10, scale: 2, null: false
      t.string :transaction_type, null: false
      t.date :transaction_date, null: false
      t.text :notes
      t.string :receipt_url
      t.json :metadata

      t.timestamps
    end

    add_index :transactions, [:project_id, :transaction_date]
    add_index :transactions, [:budget_id, :transaction_type]
    add_index :transactions, :transaction_type
    add_index :transactions, :transaction_date
    add_index :transactions, :user_id
  end
end
