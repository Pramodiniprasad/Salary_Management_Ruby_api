class SalarySlipPolicy < ApplicationPolicy
  def index?
    organization_staff? || user&.employee?
  end

  def show?
    return record.employee.user_id == user.id if user&.employee?

    organization_staff? && same_organization?
  end

  def create?
    organization_staff? && same_organization?
  end

  def update?
    organization_staff? && same_organization?
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      return scope.joins(:employee).where(employees: { user_id: user.id }) if user&.employee?
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
