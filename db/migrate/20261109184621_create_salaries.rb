class CreateSalaries < ActiveRecord::Migration[8.1]
  def change
    create_table :salaries do |t|
      t.references :organization, null: false, foreign_key: true
      t.references :employee, null: false, foreign_key: true
      t.decimal :basic_salary, precision: 12, scale: 2, null: false
      t.decimal :hra, precision: 12, scale: 2, null: false, default: 0
      t.decimal :allowances, precision: 12, scale: 2, null: false, default: 0
      t.decimal :deductions, precision: 12, scale: 2, null: false, default: 0
      t.decimal :gross_salary, precision: 12, scale: 2, null: false
      t.decimal :net_salary, precision: 12, scale: 2, null: false
      t.date :effective_from, null: false
      t.date :effective_to

      t.timestamps
    end
  end
end
