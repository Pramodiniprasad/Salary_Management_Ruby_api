require "rails_helper"

RSpec.describe SalarySlipPolicy do
  let(:salary_slip) { create(:salary_slip) }
  let(:hr) { create(:user, :hr, organization: salary_slip.organization) }

  it "allows HR within the salary slip's organization" do
    policy = described_class.new(hr, salary_slip)
    expect(policy.index?).to be(true)
    expect(policy.show?).to be(true)
    expect(policy.create?).to be(true)
    expect(policy.update?).to be(true)
  end

  it "allows employees to view only their own salary slips" do
    expect(described_class.new(salary_slip.employee.user, salary_slip).show?).to be(true)
    expect(described_class.new(create(:user), salary_slip).show?).to be(false)
  end
end
