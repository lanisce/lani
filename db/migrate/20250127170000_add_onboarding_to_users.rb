class AddOnboardingToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :onboarding_step, :string
    add_column :users, :onboarding_started_at, :datetime
    add_column :users, :onboarding_completed_at, :datetime
    add_column :users, :bio, :text
    add_column :users, :timezone, :string, default: 'UTC'
    add_column :users, :notification_preferences, :json, default: {}
    
    add_index :users, :onboarding_completed
    add_index :users, :onboarding_step
  end
end
