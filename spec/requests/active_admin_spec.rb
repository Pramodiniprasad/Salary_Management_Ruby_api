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
end
