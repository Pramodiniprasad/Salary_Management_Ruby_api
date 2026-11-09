require "rails_helper"

RSpec.describe "API access control", type: :request do
  it "requires a valid bearer token" do
    get "/api/v1/employees", headers: { "Accept" => "application/json" }

    expect(response).to have_http_status(:unauthorized)
    expect(response.parsed_body).to eq(
      "error" => "You need to sign in or sign up before continuing."
    )
  end

  it "returns a structured error for invalid login credentials" do
    post "/api/v1/auth/sign_in",
         params: { user: { email: "missing@example.com", password: "wrong" } },
         as: :json

    expect(response).to have_http_status(:unauthorized)
    expect(response.parsed_body.fetch("error")).to eq("Invalid email or password.")
  end

  it "scopes HR employee lists to their organization" do
    current_hr = create(:user, :hr)
    local_employee = create(:employee, organization: current_hr.organization)
    create(:employee)

    get "/api/v1/employees", headers: api_headers_for(current_hr)

    expect(response).to have_http_status(:ok)
    expect(response.parsed_body.fetch("data").map { |employee| employee.fetch("id") }).to eq([ local_employee.id ])
  end

  it "lets employees see only their own profile and salary" do
    employee_record = create(:employee)
    own_salary = create(:salary, employee: employee_record)
    other_salary = create(:salary)
    headers = api_headers_for(employee_record.user)

    get "/api/v1/employees/#{employee_record.id}", headers: headers
    expect(response).to have_http_status(:ok)

    get "/api/v1/employees/#{create(:employee).id}", headers: headers
    expect(response).to have_http_status(:not_found)

    get "/api/v1/salaries/#{own_salary.id}", headers: headers
    expect(response).to have_http_status(:ok)

    get "/api/v1/salaries/#{other_salary.id}", headers: headers
    expect(response).to have_http_status(:not_found)
  end

  it "denies super admins access to employee and payroll APIs" do
    super_admin = create(:user, :super_admin)

    get "/api/v1/employees", headers: api_headers_for(super_admin)

    expect(response).to have_http_status(:forbidden)
  end

  it "revokes a JWT when signing out" do
    user = create(:user, :organization_admin)
    headers = api_headers_for(user)

    delete "/api/v1/auth/sign_out", headers: headers
    expect(response).to have_http_status(:ok)

    get "/api/v1/me", headers: headers
    expect(response).to have_http_status(:unauthorized)
  end

  it "ignores a submitted organization when creating users" do
    organization_admin = create(:user, :organization_admin)
    foreign_organization = create(:organization)

    post "/api/v1/users",
         params: {
           user: {
             name: "New employee",
             email: "new@example.com",
             password: "password123",
             password_confirmation: "password123",
             role: "employee",
             organization_id: foreign_organization.id
           }
         },
         headers: api_headers_for(organization_admin),
         as: :json

    expect(response).to have_http_status(:created)
    expect(response.parsed_body.dig("data", "organization_id")).to eq(organization_admin.organization_id)
  end
end
