class ProjectMembership < ApplicationRecord
  belongs_to :user
  belongs_to :project

  # Validations
  validates :user_id, uniqueness: { scope: :project_id }
  validates :user, :project, presence: true

  # Scopes
  scope :active, -> { joins(:user).where(users: { active: true }) }
end
