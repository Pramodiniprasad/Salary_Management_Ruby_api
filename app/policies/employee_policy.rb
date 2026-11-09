class EmployeePolicy < ApplicationPolicy
  def index?
    user&.organization_admin? || user&.hr?
  end

  def show?
    return record.user_id == user.id if user&.employee?

    (user&.organization_admin? || user&.hr?) && same_organization?
  end

  def create?
    organization_staff? && same_organization?
  end

  def update?
    organization_staff? && same_organization?
  end

  def destroy?
    organization_staff? && same_organization?
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      return scope.where(user_id: user.id) if user&.employee?
      return scope.where(organization_id: user.organization_id) if user&.organization_admin? || user&.hr?

      scope.none
    end
  end

  private

  def organization_staff?
    user&.organization_admin? || user&.hr?
  end

  def same_organization?
    record.organization_id == user.organization_id
  end
end
