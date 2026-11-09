class EmployeeSerializer
  def initialize(employee)
    @employee = employee
  end

  def as_json(*)
    {
      id: @employee.id,
      organization_id: @employee.organization_id,
      user_id: @employee.user_id,
      employee_code: @employee.employee_code,
      first_name: @employee.first_name,
      last_name: @employee.last_name,
      email: @employee.email,
      phone: @employee.phone,
      designation: @employee.designation,
      department: @employee.department,
      date_of_joining: @employee.date_of_joining,
      employment_status: @employee.employment_status
    }
  end
end
