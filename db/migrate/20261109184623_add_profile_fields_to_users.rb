class AddProfileFieldsToUsers < ActiveRecord::Migration[8.1]
  def change
    add_reference :users, :organization, null: true, foreign_key: true
    add_column :users, :name, :string, null: false, default: ""
    add_column :users, :role, :integer, null: false, default: 3
    add_column :users, :status, :integer, null: false, default: 0
    add_column :users, :jti, :string, null: false

    add_index :users, :jti, unique: true
  end
end
