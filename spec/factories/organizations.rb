FactoryBot.define do
  factory :organization do
    sequence(:name) { |n| "Organization #{n}" }
    sequence(:email) { |n| "organization#{n}@example.com" }
    address { "100 Main Street" }
    phone { "555-0100" }
    status { :active }
  end
end
