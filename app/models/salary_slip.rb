class SalarySlip < ApplicationRecord
  belongs_to :organization
  belongs_to :employee
  belongs_to :salary

  enum :payment_status, { pending: 0, paid: 1 }

  validates :month, inclusion: { in: 1..12 }
  validates :year, numericality: { only_integer: true, greater_than: 2000 }
  validates :month, uniqueness: { scope: [ :employee_id, :year ] }
  validates :basic_salary, :total_earnings, :total_deductions, :net_salary,
            numericality: { greater_than_or_equal_to: 0 }
  validates :payment_date, presence: true, if: :paid?
  validate :salary_relationships_must_match

  private

  def salary_relationships_must_match
    return if employee.blank? || salary.blank? || organization.blank?
    return if salary.employee_id == employee_id &&
              salary.organization_id == organization_id &&
              employee.organization_id == organization_id

    errors.add(:salary, "must belong to the same employee and organization")
  end
end
