require "rails_helper"

RSpec.describe Salary, type: :model do
  it "calculates gross and net salary from the components" do
    salary = build(:salary, basic_salary: 5000, hra: 1000, allowances: 250, deductions: 400)

    expect(salary).to be_valid
    expect(salary.gross_salary).to eq(6250)
    expect(salary.net_salary).to eq(5850)
  end

  it "rejects a negative take-home amount" do
    salary = build(:salary, deductions: 7000)

    expect(salary).not_to be_valid
    expect(salary.errors[:net_salary]).to be_present
  end
end
