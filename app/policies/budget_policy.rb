class BudgetPolicy < ApplicationPolicy
  def index?
    user.present? && project_member?
  end

  def show?
    user.present? && project_member?
  end

  def create?
    user.present? && (project_manager? || project_owner?)
  end

  def update?
    user.present? && (project_manager? || project_owner?)
  end

  def destroy?
    user.present? && (project_manager? || project_owner?)
  end

  private

  def project
    @project ||= record.is_a?(Budget) ? record.project : record
  end

  def project_member?
    return false unless project
    project.members.include?(user) || project.owner == user
  end

  def project_manager?
    return false unless project
    membership = project.project_memberships.find_by(user: user)
    membership&.role == 'project_manager' || project.owner == user
  end

  def project_owner?
    return false unless project
    project.owner == user
  end
end
