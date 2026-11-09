FactoryBot.define do
  factory :user do
    organization
    sequence(:name) { |n| "User #{n}" }
    sequence(:email) { |n| "user#{n}@example.com" }
    password { "password123" }
    password_confirmation { password }
    role { :employee }
    status { :active }

    trait :super_admin do
      organization { nil }
      role { :super_admin }
    end

    trait :organization_admin do
      role { :organization_admin }
    end

    trait :hr do
      role { :hr }
    end
  end
end
