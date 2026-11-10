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
         headers: { "Origin" => "http://localhost:5173" },
         as: :json

    expect(response).to have_http_status(:unauthorized)
    expect(response.parsed_body.fetch("error")).to eq("Invalid email or password.")
    expect(response.headers["Access-Control-Allow-Origin"]).to eq("http://localhost:5173")
  end

  it "scopes HR employee lists to their organization" do
    current_hr = create(:user, :hr)
    local_employee = create(:employee, organization: current_hr.organization)
    create(:employee)

    get "/api/v1/employees", headers: api_headers_for(current_hr)

    expect(response).to have_http_status(:ok)
    expect(response.parsed_body.fetch("data").map { |employee| employee.fetch("id") }).to eq([ local_employee.id ])
  end

  it "lets an HR user update their own profile but not role or organization" do
    hr = create(:user, :hr)
    other_organization = create(:organization)
    original_organization_id = hr.organization_id

    patch "/api/v1/me",
          params: {
            user: {
              name: "Updated HR",
              email: "updated-hr@example.com",
              role: "super_admin",
              organization_id: other_organization.id
            }
          },
          headers: api_headers_for(hr),
          as: :json

    expect(response).to have_http_status(:ok)
    expect(response.parsed_body.dig("data", "name")).to eq("Updated HR")
    expect(hr.reload).to have_attributes(
      name: "Updated HR",
      email: "updated-hr@example.com",
      role: "hr",
      organization_id: original_organization_id
    )
  end

  it "returns the organization name in the current-user response" do
    hr = create(:user, :hr)

    get "/api/v1/me", headers: api_headers_for(hr)

    expect(response).to have_http_status(:ok)
    expect(response.parsed_body.dig("data", "organization")).to eq("name" => hr.organization.name)
  end

  it "returns the organization name in salary-slip responses" do
    slip = create(:salary_slip)
    hr = create(:user, :hr, organization: slip.organization)

    get "/api/v1/salary_slips/#{slip.id}", headers: api_headers_for(hr)

    expect(response).to have_http_status(:ok)
    expect(response.parsed_body.dig("data", "organization")).to eq("name" => slip.organization.name)
  end

  it "filters salary slips by month and year" do
    employee = create(:employee)
    salary = create(:salary, employee: employee)
    november_slip = create(:salary_slip, salary: salary, employee: employee, organization: employee.organization,
                                        month: 11, year: 2026)
    create(:salary_slip, salary: salary, employee: employee, organization: employee.organization,
                         month: 1, year: 2026)
    hr = create(:user, :hr, organization: employee.organization)

    get "/api/v1/salary_slips",
        params: { month: 11, year: 2026 },
        headers: api_headers_for(hr)

    expect(response).to have_http_status(:ok)
    expect(response.parsed_body.fetch("data").map { |slip| slip.fetch("id") }).to eq([ november_slip.id ])
  end

  it "paginates salary results" do
    hr = create(:user, :hr)
    employee = create(:employee, organization: hr.organization)
    salary_one = create(:salary, employee: employee, organization: hr.organization)
    salary_two = create(:salary, employee: employee, organization: hr.organization, effective_from: Date.current + 1.day)
    create(:salary, employee: employee, organization: hr.organization, effective_from: Date.current + 2.days)

    get "/api/v1/salaries", params: { page: 2, per_page: 1 }, headers: api_headers_for(hr)

    expect(response).to have_http_status(:ok)
    expect(response.parsed_body.fetch("data").pluck("id")).to eq([ salary_two.id ])
    expect(response.parsed_body.fetch("meta")).to eq(
      "page" => 2,
      "per_page" => 1,
      "next_page" => 3
    )
  end

  it "rejects invalid pagination parameters" do
    hr = create(:user, :hr)

    get "/api/v1/salaries", params: { page: 0, per_page: 500 }, headers: api_headers_for(hr)

    expect(response).to have_http_status(:bad_request)
    expect(response.parsed_body.fetch("error")).to eq("bad_request")
  end

  it "allows an HR user to change their password with the current password and confirmation" do
    hr = create(:user, :hr)

    patch "/api/v1/me",
          params: {
            user: {
              current_password: "password123",
              password: "new-password123",
              password_confirmation: "new-password123"
            }
          },
          headers: api_headers_for(hr),
          as: :json

    expect(response).to have_http_status(:ok)
    expect(hr.reload.valid_password?("new-password123")).to be(true)
  end

  it "rejects a password change when the current password is incorrect" do
    hr = create(:user, :hr)

    patch "/api/v1/me",
          params: {
            user: {
              current_password: "wrong-password",
              password: "new-password123",
              password_confirmation: "new-password123"
            }
          },
          headers: api_headers_for(hr),
          as: :json

    expect(response).to have_http_status(:unprocessable_content)
    expect(response.parsed_body.fetch("errors")).to have_key("current_password")
    expect(hr.reload.valid_password?("password123")).to be(true)
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

  it "returns validation errors for an invalid employee employment status" do
    employee_record = create(:employee)

    patch "/api/v1/employees/#{employee_record.id}",
          params: {
            employee: {
              id: employee_record.id,
              organization_id: employee_record.organization_id,
              user_id: employee_record.user_id,
              employee_code: employee_record.employee_code,
              first_name: employee_record.first_name,
              last_name: employee_record.last_name,
              email: employee_record.email,
              phone: employee_record.phone,
              designation: employee_record.designation,
              department: employee_record.department,
              date_of_joining: employee_record.date_of_joining,
              employment_status: "inactive"
            }
          },
          headers: api_headers_for(create(:user, :hr, organization: employee_record.organization)),
          as: :json

    expect(response).to have_http_status(:unprocessable_content)
    expect(response.parsed_body.dig("errors", "employment_status")).to include("is not included in the list")
    expect(employee_record.reload).to be_active
  end

  it "ignores read-only employee fields when updating an employee" do
    employee_record = create(:employee)
    other_organization = create(:organization)
    hr = create(:user, :hr, organization: employee_record.organization)

    patch "/api/v1/employees/#{employee_record.id}",
          params: {
            employee: {
              organization_id: other_organization.id,
              user_id: create(:user, :employee, organization: other_organization).id,
              first_name: "Updated",
              employment_status: "on_leave"
            }
          },
          headers: api_headers_for(hr),
          as: :json

    expect(response).to have_http_status(:ok)
    expect(employee_record.reload).to have_attributes(
      first_name: "Updated",
      organization_id: hr.organization_id,
      user_id: employee_record.user_id,
      employment_status: "on_leave"
    )
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
