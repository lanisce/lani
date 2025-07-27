class Project < ApplicationRecord
  # Associations
  belongs_to :owner, class_name: 'User'
  has_many :project_memberships, dependent: :destroy
  has_many :members, through: :project_memberships, source: :user
  has_many :tasks, dependent: :destroy
  has_many :budgets, dependent: :destroy
  has_many :transactions, through: :budgets, dependent: :destroy

  # Enums
  enum status: {
    planning: 0,
    active: 1,
    on_hold: 2,
    completed: 3,
    cancelled: 4
  }

  # Validations
  validates :name, presence: true, length: { maximum: 100 }
  validates :description, length: { maximum: 1000 }
  validates :status, presence: true
  validates :owner, presence: true

  # Scopes
  scope :active_projects, -> { where(status: [:planning, :active]) }
  scope :by_status, ->(status) { where(status: status) }
  scope :owned_by, ->(user) { where(owner: user) }

  # Location fields for Mapbox integration
  validates :latitude, :longitude, numericality: true, allow_nil: true

  def has_location?
    latitude.present? && longitude.present?
  end

  def location_coordinates
    return nil unless has_location?
    [longitude, latitude] # GeoJSON format: [lng, lat]
  end

  def progress_percentage
    return 0 if tasks.count == 0
    completed_tasks = tasks.where(status: :completed).count
    (completed_tasks.to_f / tasks.count * 100).round(1)
  end

  def total_budget
    budgets.sum(:amount)
  end

  def spent_amount
    transactions.sum(:amount)
  end

  def remaining_budget
    total_budget - spent_amount
  end

  def can_be_edited_by?(user)
    return false unless user
    user.admin? || owner == user || user.project_manager?
  end

  def can_be_viewed_by?(user)
    return false unless user
    return true if user.admin? || owner == user
    members.include?(user)
  end
end
