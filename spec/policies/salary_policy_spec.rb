require "rails_helper"

RSpec.describe SalaryPolicy do
  let(:salary) { create(:salary) }
  let(:hr) { create(:user, :hr, organization: salary.organization) }

  it "allows HR within the salary's organization" do
    policy = described_class.new(hr, salary)
    expect(policy.index?).to be(true)
    expect(policy.show?).to be(true)
    expect(policy.create?).to be(true)
    expect(policy.update?).to be(true)
    expect(policy.destroy?).to be(true)
  end

  it "allows employees to view only their own salary" do
    expect(described_class.new(salary.employee.user, salary).show?).to be(true)
    expect(described_class.new(create(:user), salary).show?).to be(false)
  end

  it "denies super admins access to salary records" do
    expect(described_class.new(create(:user, :super_admin), salary).show?).to be(false)
  end
end
