FactoryBot.define do
  factory :salary_slip do
    salary
    employee { salary.employee }
    organization { employee.organization }
    month { 1 }
    year { 2025 }
    basic_salary { salary.basic_salary }
    total_earnings { salary.gross_salary }
    total_deductions { salary.deductions }
    net_salary { salary.net_salary }
    payment_status { :pending }
  end
end
