# frozen_string_literal: true

class TaskPolicy < ApplicationPolicy
  def index?
    return false unless user
    record.respond_to?(:project) ? ProjectPolicy.new(user, record.project).show? : user.present?
  end

  def show?
    return false unless user
    admin? || owner? || member? || assigned_to_user?
  end

  def create?
    return false unless user
    return false unless record.respond_to?(:project)
    ProjectPolicy.new(user, record.project).update?
  end

  def update?
    return false unless user
    admin? || owner? || assigned_to_user? || project_manager?
  end

  def destroy?
    return false unless user
    admin? || owner? || (project_manager? && ProjectPolicy.new(user, record.project).update?)
  end

  def assign?
    return false unless user
    admin? || owner? || project_manager?
  end

  class Scope < Scope
    def resolve
      return scope.none unless user

      if user.admin?
        scope.all
      elsif user.project_manager?
        # Project managers can see all tasks
        scope.joins(:project)
      else
        # Regular users can only see tasks from projects they have access to
        scope.joins(:project)
             .joins("LEFT JOIN project_memberships ON projects.id = project_memberships.project_id")
             .where(
               "projects.owner_id = ? OR project_memberships.user_id = ? OR tasks.user_id = ?",
               user.id, user.id, user.id
             ).distinct
      end
    end
  end

  private

  def assigned_to_user?
    record.respond_to?(:user) && record.user == user
  end
end
