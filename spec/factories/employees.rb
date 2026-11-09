FactoryBot.define do
  factory :employee do
    organization
    user { association :user, organization: organization, role: :employee }
    sequence(:employee_code) { |n| "EMP-#{n}" }
    sequence(:first_name) { |n| "First#{n}" }
    last_name { "Employee" }
    sequence(:email) { |n| "employee#{n}@example.com" }
    phone { "555-0101" }
    designation { "Engineer" }
    department { "Technology" }
    date_of_joining { Date.new(2024, 1, 1) }
    employment_status { :active }
  end
end
