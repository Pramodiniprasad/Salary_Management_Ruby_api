class UserPolicy < ApplicationPolicy
  def index?
    user&.organization_admin? || user&.hr?
  end

  def show?
    return true if record == user

    (user&.organization_admin? || user&.hr?) &&
      record.organization_id == user.organization_id
  end

  def update?
    record == user
  end

  def create?
    return false unless record.organization_id == user.organization_id

    (user.organization_admin? && (record.hr? || record.employee?)) ||
      (user.hr? && record.employee?)
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      return scope.where(id: user.id) if user&.employee?
      return scope.where(organization_id: user.organization_id) if user&.organization_admin? || user&.hr?

      scope.none
    end
  end
end
