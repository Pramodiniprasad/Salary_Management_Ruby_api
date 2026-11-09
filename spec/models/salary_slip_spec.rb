require "rails_helper"

RSpec.describe SalarySlip, type: :model do
  it "requires one slip per employee period" do
    slip = create(:salary_slip)
    duplicate = build(:salary_slip, employee: slip.employee, salary: slip.salary,
                                    organization: slip.organization, month: slip.month, year: slip.year)

    expect(duplicate).not_to be_valid
    expect(duplicate.errors[:month]).to be_present
  end

  it "requires a payment date when marked paid" do
    slip = build(:salary_slip, payment_status: :paid, payment_date: nil)

    expect(slip).not_to be_valid
    expect(slip.errors[:payment_date]).to include("can't be blank")
  end
end
