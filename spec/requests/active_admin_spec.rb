require "rails_helper"

RSpec.describe "ActiveAdmin super-admin panel", type: :request do
  include Devise::Test::IntegrationHelpers

  it "renders sign-in with ActiveAdmin's logged-out layout" do
    get "/admin/login", headers: {
      "User-Agent" => "Mozilla/5.0 Chrome/120.0.0.0 Safari/537.36"
    }

    expect(response).to have_http_status(:ok)
    expect(response.body).to include('class="active_admin logged_out new"', 'id="login"')
    expect(response.body).to include("/assets/active_admin")
  end

  it "shows organization counts without exposing employee or payroll records" do
    organization = create(:organization)
    employee = create(:employee, organization: organization)
    create(:salary, employee: employee)
    sign_in create(:user, :super_admin)

    get "/admin/organizations", headers: {
      "User-Agent" => "Mozilla/5.0 Chrome/120.0.0.0 Safari/537.36"
    }

    expect(response).to have_http_status(:ok)
    expect(response.body).to include(organization.name, "Users", "1")
    expect(response.body).not_to include(employee.email, "5000.00")

    patch "/admin/organizations/#{organization.id}",
          params: { organization: { status: "inactive" } },
          headers: { "User-Agent" => "Mozilla/5.0 Chrome/120.0.0.0 Safari/537.36" }

    expect(response).to have_http_status(:redirect)
    expect(organization.reload).to be_inactive
  end

  it "denies non-super-admin users" do
    sign_in create(:user, :hr)

    get "/admin/organizations", headers: {
      "User-Agent" => "Mozilla/5.0 Chrome/120.0.0.0 Safari/537.36"
    }

    expect(response).to have_http_status(:forbidden)
  end

  it "lets a super admin provision an organization admin" do
    organization = create(:organization)
    sign_in create(:user, :super_admin)

    get "/admin/organizations/#{organization.id}/create_admin",
        headers: { "User-Agent" => "Mozilla/5.0 Chrome/120.0.0.0 Safari/537.36" }

    expect(response).to have_http_status(:ok)
    expect(response.body).to include("Add an administrator", "password_confirmation")

    post "/admin/organizations/#{organization.id}/create_admin",
         params: {
           user: {
             name: "Organization Admin",
             email: "org-admin@example.com",
             password: "password123",
             password_confirmation: "password123"
           }
         },
         headers: { "User-Agent" => "Mozilla/5.0 Chrome/120.0.0.0 Safari/537.36" }

    expect(response).to have_http_status(:redirect)
    expect(organization.users.organization_admin.pluck(:email)).to eq([ "org-admin@example.com" ])
    expect(organization.users.employee).to be_empty
  end

  it "lets a super admin edit an organization admin without exposing employee users" do
    organization = create(:organization)
    admin = create(:user, :organization_admin, organization: organization, email: "before@example.com")
    original_password = admin.encrypted_password
    employee = create(:employee, organization: organization)
    sign_in create(:user, :super_admin)
    headers = { "User-Agent" => "Mozilla/5.0 Chrome/120.0.0.0 Safari/537.36" }

    get "/admin/organizations/#{organization.id}"
    expect(response.body).to include(admin.email, "Edit")
    expect(response.body).not_to include(employee.email)

    get "/admin/organizations/#{organization.id}/edit_admin?user_id=#{admin.id}", headers: headers
    expect(response).to have_http_status(:ok)
    expect(response.body).to include("Edit administrator", "Leave blank to keep the current password.")

    patch "/admin/organizations/#{organization.id}/edit_admin",
          params: { user_id: admin.id, user: { name: "Updated Admin", email: "after@example.com", status: "inactive" } },
          headers: headers

    expect(response).to have_http_status(:redirect)
    expect(admin.reload).to have_attributes(name: "Updated Admin", email: "after@example.com", status: "inactive")
    expect(admin.encrypted_password).to eq(original_password)
  end

  it "requires confirmation when changing an organization admin password" do
    organization = create(:organization)
    admin = create(:user, :organization_admin, organization: organization)
    sign_in create(:user, :super_admin)
    headers = { "User-Agent" => "Mozilla/5.0 Chrome/120.0.0.0 Safari/537.36" }

    patch "/admin/organizations/#{organization.id}/edit_admin",
          params: { user_id: admin.id, user: { password: "new-password123" } },
          headers: headers

    expect(response).to have_http_status(:unprocessable_content)
    expect(response.body).to include("Password confirmation")
  end

  it "does not allow editing an admin from another organization" do
    organization = create(:organization)
    other_admin = create(:user, :organization_admin)
    sign_in create(:user, :super_admin)

    get "/admin/organizations/#{organization.id}/edit_admin?user_id=#{other_admin.id}",
        headers: { "User-Agent" => "Mozilla/5.0 Chrome/120.0.0.0 Safari/537.36" }

    expect(response).to have_http_status(:not_found)
  end
end
