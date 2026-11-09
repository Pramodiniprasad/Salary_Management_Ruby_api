require "rails_helper"

RSpec.describe Employee, type: :model do
  it "requires an employee user from the same organization" do
    organization = create(:organization)
    employee = build(:employee, organization: organization, user: create(:user, :hr, organization: organization))

    expect(employee).not_to be_valid
    expect(employee.errors[:user]).to include("must be an employee in the same organization")
  end

  it "does not allow duplicate employee codes within an organization" do
    employee = create(:employee)
    duplicate = build(:employee, organization: employee.organization, employee_code: employee.employee_code)

    expect(duplicate).not_to be_valid
  end
end
