# Salary Management System

Organization-based salary management backend built with Ruby on Rails, PostgreSQL, Devise/JWT, ActiveAdmin, Pundit, RSpec, and FactoryBot.

## Structure

- `app/models/`: domain records, validations, and associations.
- `app/controllers/api/v1/`: versioned JSON API endpoints.
- `app/policies/`: role and organization access rules.
- `app/serializers/`: stable API response shapes.
- `app/admin/`: Rails-rendered ActiveAdmin dashboard and organization administration.
- `db/migrate/`: individual migrations for users, organizations, employees, salaries, and slips.
- `spec/`: model, policy, and request tests; `spec/factories/` contains FactoryBot data.
- `docs/api_endpoints.json`: ordered frontend integration contract.

## Database design and associations

- `Organization` has many users, employees, salaries, and salary slips.
- `User` belongs to an optional organization and can have one employee profile. Only super admins may lack an organization. Devise stores `encrypted_password`, the secure equivalent of the requested password digest.
- `Employee` belongs to one organization and one user, and has many salary records and salary slips.
- `Salary` belongs to an organization and employee. Gross/net amounts are calculated from the salary components.
- `SalarySlip` belongs to an organization, employee, and salary, and snapshots the amounts for a payroll period.

Foreign keys and unique indexes protect organization emails, employee accounts, employee codes per organization, and one slip per employee/month/year.

The Rails-rendered super-admin panel is at `/admin`. It manages organizations, activation status, organization-wise user counts, and organization-admin accounts. On an organization's show page, super admins can add an organization admin or edit an existing admin's name, email, status, and (optionally) password. It does not expose employee or payroll resources.

## Setup

Requirements: Ruby 3.3+, Rails 8.1, and PostgreSQL.

```sh
bundle install
bin/rails db:prepare
```

Configure PostgreSQL with `DATABASE_URL` or `PGHOST`/`PGUSER`/`PGPASSWORD`. Set `super_admin.password` in encrypted Rails credentials with `bin/rails credentials:edit`, then run `bin/rails db:seed` to create or update the initial super admin (`admin@gmail.com`).

```sh
bin/rails db:seed
```

The default React origin is `http://localhost:3000`; set `FRONTEND_ORIGIN` for another origin. JWTs are returned in the `Authorization: Bearer <jwt>` response header and expire after one hour. See [docs/api_endpoints.json](docs/api_endpoints.json) for request/response shapes.

In development, the seed also creates up to 10,000 synthetic employees for the organization with email `incubyte@gmail.com`, one salary per employee effective from the start of the current year, and one pending salary slip for the current month. The seeded employee login is `employee00001@incubyte.example` with password `Test@0001`; in general, `employeeNNNNN@incubyte.example` uses password `Test@NNNN` (the numeric employee sequence padded to at least four digits). The seed sets these passwords only in development. Do not use this predictable password pattern in production. Seed runs are idempotent.

Authenticated users can update their own name and email with `PATCH /api/v1/me`. The `GET /api/v1/me` response includes `organization: { name: ... }` when the user belongs to an organization. Salary-slip responses also include the organization name for payslip rendering. To change a password, include `current_password`, `password`, and `password_confirmation` in the same `user` object. Role and organization fields cannot be changed through this endpoint.

Salary and salary-slip list endpoints are paginated (`page`, default `1`; `per_page`, default `50`, maximum `100`). Responses include `meta.page`, `meta.per_page`, and `meta.next_page`. Salary slips also support `month` and `year` filters. For example, request `/api/v1/salary_slips?month=11&year=2026&page=1&per_page=50`.

## Tests

```sh
bundle exec rspec
```
