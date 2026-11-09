class CreateEmployees < ActiveRecord::Migration[8.1]
  def change
    create_table :employees do |t|
      t.references :organization, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true, index: { unique: true }
      t.string :employee_code, null: false
      t.string :first_name, null: false
      t.string :last_name, null: false
      t.string :email, null: false
      t.string :phone
      t.string :designation, null: false
      t.string :department, null: false
      t.date :date_of_joining, null: false
      t.integer :employment_status, null: false, default: 0

      t.timestamps
    end

    add_index :employees, [ :organization_id, :employee_code ], unique: true
  end
end
