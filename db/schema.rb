# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_11_10_225000) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "active_admin_comments", force: :cascade do |t|
    t.string "namespace"
    t.text "body"
    t.string "resource_type"
    t.bigint "resource_id"
    t.string "author_type"
    t.bigint "author_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["author_type", "author_id"], name: "index_active_admin_comments_on_author"
    t.index ["namespace"], name: "index_active_admin_comments_on_namespace"
    t.index ["resource_type", "resource_id"], name: "index_active_admin_comments_on_resource"
  end

  create_table "employees", force: :cascade do |t|
    t.bigint "organization_id", null: false
    t.bigint "user_id", null: false
    t.string "employee_code", null: false
    t.string "first_name", null: false
    t.string "last_name", null: false
    t.string "email", null: false
    t.string "phone"
    t.string "designation", null: false
    t.string "department", null: false
    t.date "date_of_joining", null: false
    t.integer "employment_status", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["organization_id", "employee_code"], name: "index_employees_on_organization_id_and_employee_code", unique: true
    t.index ["organization_id"], name: "index_employees_on_organization_id"
    t.index ["user_id"], name: "index_employees_on_user_id", unique: true
  end

  create_table "organizations", force: :cascade do |t|
    t.string "name", null: false
    t.string "email", null: false
    t.text "address"
    t.string "phone"
    t.integer "status", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_organizations_on_email", unique: true
  end

  create_table "salaries", force: :cascade do |t|
    t.bigint "organization_id", null: false
    t.bigint "employee_id", null: false
    t.decimal "basic_salary", precision: 12, scale: 2, null: false
    t.decimal "hra", precision: 12, scale: 2, default: "0.0", null: false
    t.decimal "allowances", precision: 12, scale: 2, default: "0.0", null: false
    t.decimal "deductions", precision: 12, scale: 2, default: "0.0", null: false
    t.decimal "gross_salary", precision: 12, scale: 2, null: false
    t.decimal "net_salary", precision: 12, scale: 2, null: false
    t.date "effective_from", null: false
    t.date "effective_to"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["employee_id"], name: "index_salaries_on_employee_id"
    t.index ["organization_id"], name: "index_salaries_on_organization_id"
  end

  create_table "salary_slips", force: :cascade do |t|
    t.bigint "organization_id", null: false
    t.bigint "employee_id", null: false
    t.bigint "salary_id", null: false
    t.integer "month", null: false
    t.integer "year", null: false
    t.decimal "basic_salary", precision: 12, scale: 2, null: false
    t.decimal "total_earnings", precision: 12, scale: 2, null: false
    t.decimal "total_deductions", precision: 12, scale: 2, null: false
    t.decimal "net_salary", precision: 12, scale: 2, null: false
    t.integer "payment_status", default: 0, null: false
    t.date "payment_date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["employee_id", "year", "month"], name: "index_salary_slips_on_employee_id_and_year_and_month", unique: true
    t.index ["employee_id"], name: "index_salary_slips_on_employee_id"
    t.index ["organization_id", "year", "month", "id"], name: "index_salary_slips_on_organization_and_period", order: { year: :desc, month: :desc, id: :desc }
    t.index ["organization_id"], name: "index_salary_slips_on_organization_id"
    t.index ["salary_id"], name: "index_salary_slips_on_salary_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "organization_id"
    t.string "name", default: "", null: false
    t.integer "role", default: 3, null: false
    t.integer "status", default: 0, null: false
    t.string "jti", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["jti"], name: "index_users_on_jti", unique: true
    t.index ["organization_id"], name: "index_users_on_organization_id"
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "employees", "organizations"
  add_foreign_key "employees", "users"
  add_foreign_key "salaries", "employees"
  add_foreign_key "salaries", "organizations"
  add_foreign_key "salary_slips", "employees"
  add_foreign_key "salary_slips", "organizations"
  add_foreign_key "salary_slips", "salaries"
  add_foreign_key "users", "organizations"
end
