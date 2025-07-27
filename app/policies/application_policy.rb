# frozen_string_literal: true

class ApplicationPolicy
  attr_reader :user, :record

  def initialize(user, record)
    @user = user
    @record = record
  end

  def index?
    false
  end

  def show?
    false
  end

  def create?
    false
  end

  def new?
    create?
  end

  def update?
    false
  end

  def edit?
    update?
  end

  def destroy?
    false
  end

  class Scope
    def initialize(user, scope)
      @user = user
      @scope = scope
    end

    def resolve
      raise NotImplementedError, "You must define #resolve in #{self.class}"
    end

    private

    attr_reader :user, :scope
  end

  private

  def admin?
    user&.admin?
  end

  def project_manager?
    user&.project_manager?
  end

  def owner?
    record.respond_to?(:owner) && record.owner == user
  end

  def member?
    return false unless user
    return true if admin? || project_manager?
    
    if record.respond_to?(:project)
      record.project.members.include?(user) || record.project.owner == user
    elsif record.respond_to?(:members)
      record.members.include?(user) || record.owner == user
    else
      false
    end
  end
end
