# Salary Management System – Ruby on Rails Backend

Build the backend for an Organisation-Based Salary Management System using Ruby on Rails and PostgreSQL.

### Technology

- Ruby on Rails (standard MVC architecture and Ruby syntax).
- PostgreSQL.
- Devise for authentication.
- Pundit for authorization.
- REST APIs for React frontend.
- Use standard Rails gems and conventions.

### 1. Super Admin Panel (Rails Views)

Build the Super Admin panel completely in Rails.

Super Admin can:

- Create, edit and update organisations.
- Activate/deactivate organisations.
- View all organisations.
- View organisation-wise user counts.

Super Admin cannot access employee personal details, salary details, salary slips or HR analytics.

### 2. User Roles

Use a single `users` table with a `role` attribute.

Roles:

- super_admin
- organization_admin
- hr
- employee

Organisation Admin, HR and Employee must belong to an organisation through `organization_id`.

### 3. Database Models and Attributes

**Organization**

- name
- email
- address
- phone
- status

**User**

- organization_id (nullable for super admin)
- name
- email
- password_digest
- role
- status

**Employee**

- organization_id
- user_id
- employee_code
- first_name
- last_name
- email
- phone
- designation
- department
- date_of_joining
- employment_status

**Salary**

- organization_id
- employee_id
- basic_salary
- hra
- allowances
- deductions
- gross_salary
- net_salary
- effective_from
- effective_to

**SalarySlip**

- organization_id
- employee_id
- salary_id
- month
- year
- basic_salary
- total_earnings
- total_deductions
- net_salary
- payment_status
- payment_date

### 4. Model Associations

- Organization has many users and employees.
- Employee belongs to organization and user.
- Employee has many salaries and salary slips.
- Salary belongs to employee and organization.
- SalarySlip belongs to employee, salary and organization.

### 5. Backend Requirements

- Follow Rails MVC structure.
- Create migrations with foreign keys and indexes.
- Add model validations.
- Implement authentication and role-based authorization.
- Use Pundit policies.
- Implement organisation-level data isolation.
- Create REST APIs for React.
- Use controllers, services and serializers where required.
- Add API error handling.
- Write model, controller and policy tests.

### 6. Security

- Users must access only their own organisation's data.
- HR cannot access another organisation.
- Employees can view only their own profile and salary.
- Super Admin cannot access salary or employee details.
- Enforce all permissions in Rails.

### 7. Development Instructions

- Use simple Ruby code and standard Rails syntax.
- Follow basic Rails naming conventions.
- Use only required gems.
- Do not use MongoDB.
- Keep business logic organised.
- Build and test modules step by step.

First explain the folder structure, database design and associations. Then implement authentication, Super Admin panel, policies, models and APIs. Do not skip tests.
