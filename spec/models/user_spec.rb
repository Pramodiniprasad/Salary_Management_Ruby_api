require "rails_helper"

RSpec.describe User, type: :model do
  it "allows a super admin without an organization" do
    expect(build(:user, :super_admin, organization: nil)).to be_valid
  end

  it "requires an organization for organization users" do
    user = build(:user, organization: nil)

    expect(user).not_to be_valid
    expect(user.errors[:organization]).to include("can't be blank")
  end

  it "blocks authentication when its organization is inactive" do
    user = build(:user, organization: build(:organization, status: :inactive))

    expect(user).not_to be_active_for_authentication
  end
end
