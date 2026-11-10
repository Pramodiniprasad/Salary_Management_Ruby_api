class SalarySlipSerializer
  def initialize(salary_slip)
    @salary_slip = salary_slip
  end

  def as_json(*)
    {
      id: @salary_slip.id,
      employee_id: @salary_slip.employee_id,
      salary_id: @salary_slip.salary_id,
      organization: { name: @salary_slip.organization.name },
      month: @salary_slip.month,
      year: @salary_slip.year,
      basic_salary: @salary_slip.basic_salary,
      total_earnings: @salary_slip.total_earnings,
      total_deductions: @salary_slip.total_deductions,
      net_salary: @salary_slip.net_salary,
      payment_status: @salary_slip.payment_status,
      payment_date: @salary_slip.payment_date
    }
  end
end
