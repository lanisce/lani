# frozen_string_literal: true

class ProjectPolicy < ApplicationPolicy
  def index?
    user.present?
  end

  def show?
    return false unless user
    admin? || owner? || member?
  end

  def create?
    user.present? && (admin? || project_manager?)
  end

  def update?
    return false unless user
    admin? || owner? || project_manager?
  end

  def destroy?
    return false unless user
    admin? || owner?
  end

  def manage_members?
    return false unless user
    admin? || owner? || project_manager?
  end

  class Scope < Scope
    def resolve
      return scope.none unless user

      if user.admin?
        scope.all
      elsif user.project_manager?
        # Project managers can see all projects
        scope.all
      else
        # Regular users can only see projects they own or are members of
        scope.joins("LEFT JOIN project_memberships ON projects.id = project_memberships.project_id")
             .where(
               "projects.owner_id = ? OR project_memberships.user_id = ?",
               user.id, user.id
             ).distinct
      end
    end
  end
end
