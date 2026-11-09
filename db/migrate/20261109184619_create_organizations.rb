class CreateOrganizations < ActiveRecord::Migration[8.1]
  def change
    create_table :organizations do |t|
      t.string :name, null: false
      t.string :email, null: false
      t.text :address
      t.string :phone
      t.integer :status, null: false, default: 0

      t.timestamps
    end

    add_index :organizations, :email, unique: true
  end
end
