class CreateSalarySlips < ActiveRecord::Migration[8.1]
  def change
    create_table :salary_slips do |t|
      t.references :organization, null: false, foreign_key: true
      t.references :employee, null: false, foreign_key: true
      t.references :salary, null: false, foreign_key: true
      t.integer :month, null: false
      t.integer :year, null: false
      t.decimal :basic_salary, precision: 12, scale: 2, null: false
      t.decimal :total_earnings, precision: 12, scale: 2, null: false
      t.decimal :total_deductions, precision: 12, scale: 2, null: false
      t.decimal :net_salary, precision: 12, scale: 2, null: false
      t.integer :payment_status, null: false, default: 0
      t.date :payment_date

      t.timestamps
    end

    add_index :salary_slips, [ :employee_id, :year, :month ], unique: true
  end
end
