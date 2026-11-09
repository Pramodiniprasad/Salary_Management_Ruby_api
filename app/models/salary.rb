class Salary < ApplicationRecord
  belongs_to :organization
  belongs_to :employee

  has_many :salary_slips, dependent: :restrict_with_error

  before_validation :calculate_totals

  validates :basic_salary, :gross_salary, :net_salary, :effective_from,
            presence: true
  validates :basic_salary, :hra, :allowances, :deductions, :gross_salary,
            :net_salary, numericality: { greater_than_or_equal_to: 0 }
  validate :organization_must_match_employee
  validate :effective_to_must_follow_effective_from

  private

  def calculate_totals
    self.gross_salary = basic_salary.to_d + hra.to_d + allowances.to_d
    self.net_salary = gross_salary - deductions.to_d
  end

  def organization_must_match_employee
    return if employee.blank? || organization_id == employee.organization_id

    errors.add(:organization, "must match the employee's organization")
  end

  def effective_to_must_follow_effective_from
    return if effective_to.blank? || effective_from.blank? || effective_to >= effective_from

    errors.add(:effective_to, "must be on or after the effective start date")
  end
end
