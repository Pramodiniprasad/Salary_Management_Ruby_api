# frozen_string_literal: true

ActiveAdmin.register_page "Dashboard" do
  menu priority: 1, label: proc { I18n.t("active_admin.dashboard") }

  content title: proc { I18n.t("active_admin.dashboard") } do
    columns do
      column do
        panel "Organization overview" do
          table_for Organization.order(:name) do
            column(:name) { |organization| link_to organization.name, admin_organization_path(organization) }
            column(:status)
            column("Users") { |organization| organization.user_count }
          end
        end
      end
    end
  end
end
