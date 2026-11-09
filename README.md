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

The Rails-rendered super-admin panel is at `/admin`. It manages organizations, activation status, organization-wise user counts, and provisioning the first organization administrator. It does not expose employee or payroll resources.

## Setup

Requirements: Ruby 3.3+, Rails 8.1, and PostgreSQL.

```sh
bundle install
bin/rails db:prepare
```

Configure PostgreSQL with `DATABASE_URL` or `PGHOST`/`PGUSER`/`PGPASSWORD`. To create the initial super admin, set `SUPER_ADMIN_EMAIL` and `SUPER_ADMIN_PASSWORD` (optionally `SUPER_ADMIN_NAME`) and run:

```sh
bin/rails db:seed
```

The default React origin is `http://localhost:3000`; set `FRONTEND_ORIGIN` for another origin. JWTs are returned in the `Authorization: Bearer <jwt>` response header and expire after one hour. See [docs/api_endpoints.json](docs/api_endpoints.json) for request/response shapes.

## Tests

```sh
bundle exec rspec
```
