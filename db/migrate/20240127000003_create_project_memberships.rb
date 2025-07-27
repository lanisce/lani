class CreateProjectMemberships < ActiveRecord::Migration[7.0]
  def change
    create_table :project_memberships do |t|
      t.references :user, null: false, foreign_key: true
      t.references :project, null: false, foreign_key: true
      t.datetime :joined_at, default: -> { 'CURRENT_TIMESTAMP' }

      t.timestamps
    end

    add_index :project_memberships, [:user_id, :project_id], unique: true
  end
end
