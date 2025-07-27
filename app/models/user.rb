class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :omniauthable, omniauth_providers: [:keycloak]

  # User roles
  enum role: {
    viewer: 0,
    member: 1,
    project_manager: 2,
    admin: 3
  }

  # Associations
  has_many :project_memberships, dependent: :destroy
  has_many :projects, through: :project_memberships
  has_many :owned_projects, class_name: 'Project', foreign_key: 'owner_id', dependent: :destroy
  has_many :tasks, dependent: :destroy
  has_many :transactions, dependent: :destroy

  # Validations
  validates :role, presence: true
  validates :first_name, :last_name, presence: true, length: { maximum: 50 }

  # Callbacks
  before_validation :set_default_role, on: :create

  # Scopes
  scope :admins, -> { where(role: :admin) }
  scope :project_managers, -> { where(role: :project_manager) }
  scope :active, -> { where(active: true) }

  def full_name
    "#{first_name} #{last_name}".strip
  end

  def display_name
    full_name.present? ? full_name : email
  end

  def admin?
    role == 'admin'
  end

  def project_manager?
    role == 'project_manager' || admin?
  end

  def can_manage_project?(project)
    admin? || project.owner == self || project_manager?
  end

  def onboarding_completed?
    onboarding_completed
  end

  private

  def set_default_role
    self.role ||= :member
  end
end
