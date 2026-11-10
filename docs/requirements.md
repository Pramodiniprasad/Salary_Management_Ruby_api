# Salary Management System — Requirements

## Goal

Provide a secure, organization-based salary-management backend and Rails-rendered super-admin panel, with a versioned JSON API for a React frontend. The system should keep each organization’s records isolated and let employees access only their own profile and payroll information.

## Scope and features

- **Organizations:** Super admins can create, view, edit, activate, and deactivate organizations and see organization-wise user counts.
- **Accounts and roles:** Use one authenticated user account per person, with roles for `super_admin`, `organization_admin`, `hr`, and `employee`. Organization roles are associated with an organization. Organization admins can manage their organization’s HR and employee accounts; HR users can manage employee accounts.
- **Organization administration:** Super admins can add and edit organization-admin accounts. The panel must not expose employee personal or payroll records.
- **Employee and payroll records:** Store employee profiles, salary components and effective dates, and monthly salary-slip snapshots with payment status and date.
- **Authentication and authorization:** Use Devise/JWT for API authentication and Pundit policies for role and organization-level access. Employees can view only their own profile and payroll records; staff can access only permitted records in their organization.
- **API:** Provide versioned JSON endpoints for authentication, current-user profile, users, employees, salaries, and salary slips. Validate inputs, return structured errors, paginate salary and slip lists, and support month/year slip filters.
- **Operations and quality:** Use PostgreSQL, separate Rails migrations for domain models, and automated model, request, and policy tests. Provide factories and development-only seed data for repeatable testing.

## Deliberately out of scope

- **Payroll disbursement, banking, and tax filing:** The system records salary and payment status but does not move money or calculate jurisdiction-specific tax. These require external providers, compliance decisions, and additional security controls.
- **Employee access to the super-admin panel or other employees’ payroll:** Restricting the panel to organization management and enforcing self-only employee access reduces exposure of sensitive data.
- **Cross-organization reporting and HR analytics for super admins:** Not required for organization administration and would violate the separation between platform operations and tenant employee data.
- **Public registration, invitation delivery, and password-reset email delivery:** Accounts are provisioned by authorized administrators; production email workflows need separate product and delivery configuration.
- **Production-quality demo accounts or predictable demo passwords:** Synthetic records and deterministic credentials are development-only and must not be used in production.

## Success criteria

Authorized users can complete their permitted organization, employee, and payroll workflows through the panel or API; cross-organization and role-restricted access is denied; employees cannot view another employee’s data; invalid requests return documented errors; and automated tests cover the principal models, policies, and API behavior.
