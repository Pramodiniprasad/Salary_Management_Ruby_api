require "rails_helper"

RSpec.describe OrganizationPolicy do
  let(:organization) { build(:organization) }

  it "allows only super admins to manage organizations" do
    policy = described_class.new(build(:user, :super_admin), organization)
    expect(policy.index?).to be(true)
    expect(policy.show?).to be(true)
    expect(policy.create?).to be(true)
    expect(policy.update?).to be(true)
    expect(described_class.new(build(:user, :hr), organization).show?).to be(false)
  end
end
