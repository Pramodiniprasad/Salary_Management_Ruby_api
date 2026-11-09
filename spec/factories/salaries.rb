FactoryBot.define do
  factory :salary do
    employee
    organization { employee.organization }
    basic_salary { 5000 }
    hra { 1000 }
    allowances { 250 }
    deductions { 400 }
    effective_from { Date.current }
  end
end
