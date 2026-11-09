# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end
admin_credentials = Rails.application.credentials.super_admin
unless admin_credentials&.password.present?
  raise "Configure super_admin.password with `bin/rails credentials:edit`."
end

super_admin = User.find_or_initialize_by(email: "admin@gmail.com")
super_admin.assign_attributes(
  name: admin_credentials.name.presence || "Super Admin",
  password: admin_credentials.password,
  role: :super_admin,
  status: :active,
  organization: nil
)
super_admin.save!
