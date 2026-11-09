require "rails_helper"

RSpec.describe UserPolicy do
  let(:organization) { create(:organization) }
  let(:other_organization) { create(:organization) }
  let(:organization_admin) { create(:user, :organization_admin, organization: organization) }
  let(:employee) { create(:user, organization: organization) }

  it "allows organization admins to create HR and employee accounts only in their organization" do
    hr = build(:user, :hr, organization: organization)
    other_user = build(:user, :employee, organization: other_organization)

    expect(described_class.new(organization_admin, hr).create?).to be(true)
    expect(described_class.new(organization_admin, other_user).create?).to be(false)
  end

  it "limits employees to their own user record" do
    other_user = create(:user, organization: organization)

    expect(described_class.new(employee, employee).show?).to be(true)
    expect(described_class.new(employee, other_user).show?).to be(false)
  end
end
