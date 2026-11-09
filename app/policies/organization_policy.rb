class OrganizationPolicy < ApplicationPolicy
  def index?
    user&.super_admin?
  end

  def show?
    user&.super_admin?
  end

  def create?
    user&.super_admin?
  end

  def update?
    user&.super_admin?
  end

  def destroy?
    false
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      user&.super_admin? ? scope.all : scope.none
    end
  end
end
