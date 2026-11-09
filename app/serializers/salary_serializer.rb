class SalarySerializer
  def initialize(salary)
    @salary = salary
  end

  def as_json(*)
    {
      id: @salary.id,
      employee_id: @salary.employee_id,
      basic_salary: @salary.basic_salary,
      hra: @salary.hra,
      allowances: @salary.allowances,
      deductions: @salary.deductions,
      gross_salary: @salary.gross_salary,
      net_salary: @salary.net_salary,
      effective_from: @salary.effective_from,
      effective_to: @salary.effective_to
    }
  end
end
