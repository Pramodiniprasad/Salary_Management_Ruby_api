require "rails_helper"

RSpec.describe Organization, type: :model do
  it "requires a name and a unique email" do
    organization = build(:organization, name: nil, email: nil)

    expect(organization).not_to be_valid
    expect(organization.errors.attribute_names).to include(:name, :email)
  end

  it "counts organization users without exposing employee information" do
    organization = create(:organization)
    create(:user, organization: organization)

    expect(organization.user_count).to eq(1)
  end
end
