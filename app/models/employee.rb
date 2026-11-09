class Employee < ApplicationRecord
  belongs_to :organization
  belongs_to :user

  has_many :salaries, dependent: :restrict_with_error
  has_many :salary_slips, dependent: :restrict_with_error

  enum :employment_status, { active: 0, on_leave: 1, terminated: 2 }

  validates :employee_code, :first_name, :last_name, :email, :designation,
            :department, :date_of_joining, presence: true
  validates :employee_code, uniqueness: { scope: :organization_id }
  validate :user_and_organization_must_match

  private

  def user_and_organization_must_match
    return if user.blank? || organization.blank?
    return if user.organization_id == organization_id && user.employee?

    errors.add(:user, "must be an employee in the same organization")
  end
end
