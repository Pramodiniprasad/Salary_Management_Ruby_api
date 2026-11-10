# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end
admin_credentials = Rails.application.credentials.super_admin
unless admin_credentials&.password.present?
  raise "Configure super_admin.password with `bin/rails credentials:edit`."
end

super_admin = User.find_or_initialize_by(email: "admin@gmail.com")
super_admin.assign_attributes(
  name: admin_credentials.name.presence || "Super Admin",
  password: admin_credentials.password,
  role: :super_admin,
  status: :active,
  organization: nil
)
super_admin.save!

if Rails.env.development?
  organization = Organization.find_by!(email: "incubyte@gmail.com")
  first_names = %w[Aarav Aditi Akash Ananya Arjun Diya Isha Kabir Karan Meera Neha Nikhil Priya Rahul Riya Rohan Saanvi Sameer Sara Vikram]
  last_names = %w[Ahmed Brown Chen Das Gupta Iyer Johnson Khan Kumar Lee Martin Mehta Miller Patel Rao Reddy Shah Singh Taylor Thomas Wilson]
  departments = %w[Engineering Finance Human\ Resources Operations Sales]
  designations = %w[Analyst Associate Engineer Manager Specialist]
  seeded_count = 0
  updated_employee_password_count = 0
  seeded_salary_count = 0
  seeded_slip_count = 0
  existing_employees = organization.employees
                                   .where(employee_code: "INC-00001".."INC-10000")
                                   .includes(:user)
                                   .index_by(&:employee_code)
  original_stretches = User.stretches
  User.stretches = BCrypt::Engine::MIN_COST

  begin
    1.upto(10_000) do |number|
      employee_code = "INC-#{number.to_s.rjust(5, "0")}"
      email = "employee#{number.to_s.rjust(5, "0")}@incubyte.example"
      employee = existing_employees[employee_code] || organization.employees.new
      user = employee.persisted? ? employee.user : User.find_or_initialize_by(email: email)
      if user.persisted? && user.organization_id != organization.id
        raise "Seed employee email #{email} is already assigned to another organization."
      end

      user.assign_attributes(
        name: "Employee #{number}",
        email: email,
        organization: organization,
        role: :employee,
        status: :active,
        password: "Test@#{number.to_s.rjust(4, "0")}"
      )
      user.save!
      updated_employee_password_count += 1

      index = number - 1
      employee.assign_attributes(
        user: user,
        organization: organization,
        employee_code: employee_code,
        first_name: first_names[index % first_names.length],
        last_name: last_names[(index / first_names.length) % last_names.length],
        email: email,
        phone: "555-01#{(number % 100).to_s.rjust(2, "0")}",
        designation: designations[number % designations.length],
        department: departments[number % departments.length],
        date_of_joining: Date.current - (number % 3_650).days,
        employment_status: :active
      )
      employee.save!
      seeded_count += 1 if employee.previously_new_record?
    end
  ensure
    User.stretches = original_stretches
  end

  salary_effective_from = Date.current.beginning_of_year
  slip_month = Date.current.month
  slip_year = Date.current.year

  organization.employees
              .where(employee_code: "INC-00001".."INC-10000")
              .find_each do |employee|
    salary = employee.salaries.find_or_initialize_by(effective_from: salary_effective_from)
    if salary.new_record?
      salary.assign_attributes(
        organization: organization,
        basic_salary: 5_000 + (employee.id % 20) * 250,
        hra: 1_000 + (employee.id % 10) * 100,
        allowances: 500 + (employee.id % 5) * 50,
        deductions: 400 + (employee.id % 8) * 25
      )
      salary.save!
      seeded_salary_count += 1
    end

    salary_slip = employee.salary_slips.find_or_initialize_by(month: slip_month, year: slip_year)
    next unless salary_slip.new_record?

    salary_slip.assign_attributes(
      organization: organization,
      salary: salary,
      basic_salary: salary.basic_salary,
      total_earnings: salary.gross_salary,
      total_deductions: salary.deductions,
      net_salary: salary.net_salary,
      payment_status: :pending
    )
    salary_slip.save!
    seeded_slip_count += 1
  end

  puts "Created #{seeded_count} synthetic employees, set passwords for #{updated_employee_password_count} employee accounts, and created #{seeded_salary_count} salaries and #{seeded_slip_count} salary slips for #{organization.name}."
end
