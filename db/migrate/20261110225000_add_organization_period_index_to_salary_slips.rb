class AddOrganizationPeriodIndexToSalarySlips < ActiveRecord::Migration[8.1]
  def change
    add_index :salary_slips, [ :organization_id, :year, :month, :id ],
              order: { year: :desc, month: :desc, id: :desc },
              name: "index_salary_slips_on_organization_and_period"
  end
end
