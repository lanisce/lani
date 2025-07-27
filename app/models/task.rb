class Task < ApplicationRecord
  belongs_to :project
  belongs_to :user, optional: true # assignee

  # Enums
  enum status: {
    todo: 0,
    in_progress: 1,
    review: 2,
    completed: 3,
    cancelled: 4
  }

  enum priority: {
    low: 0,
    medium: 1,
    high: 2,
    urgent: 3
  }

  # Validations
  validates :title, presence: true, length: { maximum: 200 }
  validates :description, length: { maximum: 2000 }
  validates :status, presence: true
  validates :priority, presence: true

  # Scopes
  scope :active, -> { where(status: [:todo, :in_progress, :review]) }
  scope :completed, -> { where(status: :completed) }
  scope :by_priority, ->(priority) { where(priority: priority) }
  scope :assigned_to, ->(user) { where(user: user) }
  scope :unassigned, -> { where(user: nil) }

  def overdue?
    due_date.present? && due_date < Date.current && !completed?
  end

  def completed?
    status == 'completed'
  end

  def can_be_edited_by?(user)
    return false unless user
    user.admin? || project.owner == user || self.user == user || user.project_manager?
  end

  def can_be_viewed_by?(user)
    return false unless user
    project.can_be_viewed_by?(user)
  end
end
