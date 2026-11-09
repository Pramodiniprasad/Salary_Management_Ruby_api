require "rails_helper"

RSpec.describe EmployeePolicy do
  let(:employee_record) { create(:employee) }
  let(:same_org_hr) { create(:user, :hr, organization: employee_record.organization) }
  let(:other_org_hr) { create(:user, :hr) }

  it "allows HR to manage employees only within the same organization" do
    policy = described_class.new(same_org_hr, employee_record)
    expect(policy.index?).to be(true)
    expect(policy.show?).to be(true)
    expect(policy.create?).to be(true)
    expect(policy.update?).to be(true)
    expect(policy.destroy?).to be(true)
    expect(described_class.new(other_org_hr, employee_record).show?).to be(false)
  end

  it "allows employees to view only their own profile" do
    expect(described_class.new(employee_record.user, employee_record).show?).to be(true)
    expect(described_class.new(create(:user), employee_record).show?).to be(false)
  end
end
