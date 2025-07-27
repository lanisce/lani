class CreateTasks < ActiveRecord::Migration[7.0]
  def change
    create_table :tasks do |t|
      t.string :title, null: false
      t.text :description
      t.integer :status, default: 0, null: false
      t.integer :priority, default: 1, null: false
      t.references :project, null: false, foreign_key: true
      t.references :user, null: true, foreign_key: true # assignee
      
      # Task scheduling
      t.date :due_date
      t.datetime :completed_at
      
      # Task estimation
      t.integer :estimated_hours
      t.integer :actual_hours
      
      t.timestamps
    end

    add_index :tasks, :status
    add_index :tasks, :priority
    add_index :tasks, :due_date
  end
end
