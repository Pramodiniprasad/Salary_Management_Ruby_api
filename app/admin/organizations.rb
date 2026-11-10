ActiveAdmin.register Organization do
  actions :all, except: [ :destroy ]
  permit_params :name, :email, :address, :phone, :status

  action_item :create_organization_admin, only: :show do
    link_to "Add organization admin", create_admin_admin_organization_path(resource)
  end

  member_action :create_admin, method: [ :get, :post ] do
    @organization = resource
    @user = @organization.users.new(role: :organization_admin)

    if request.post?
      @user.assign_attributes(params.require(:user).permit(:name, :email, :password, :password_confirmation))
      @user.role = :organization_admin

      if @user.save
        redirect_to resource_path, notice: "Organization admin created."
      else
        render "admin/organizations/create_admin", status: :unprocessable_entity
      end
    else
      render "admin/organizations/create_admin"
    end
  end

  member_action :edit_admin, method: [ :get, :patch ] do
    @organization = resource
    @user = @organization.users.organization_admin.find(params[:user_id])

    if request.patch?
      attributes = params.require(:user).permit(:name, :email, :status, :password, :password_confirmation)
      attributes.delete(:password) if attributes[:password].blank?
      attributes.delete(:password_confirmation) if attributes[:password_confirmation].blank?
      if attributes[:password].present? && attributes[:password_confirmation].blank?
        @user.errors.add(:password_confirmation, :blank)
      end

      if @user.errors.any? || !@user.update(attributes)
        render "admin/organizations/edit_admin", status: :unprocessable_entity
      else
        redirect_to resource_path, notice: "Organization admin updated."
      end
    else
      render "admin/organizations/edit_admin"
    end
  end

  index do
    selectable_column
    id_column
    column :name
    column :email
    column :phone
    column :status
    column("Users") { |organization| organization.user_count }
    actions
  end

  filter :name
  filter :email
  filter :status

  show do
    attributes_table do
      row :name
      row :email
      row :address
      row :phone
      row :status
      row("Users") { resource.user_count }
    end

    panel "Organization administrators" do
      table_for resource.users.organization_admin do
        column :name
        column :email
        column :status
        column("Actions") do |user|
          link_to "Edit", edit_admin_admin_organization_path(resource, user_id: user.id)
        end
      end
    end
  end

  form do |form|
    form.inputs do
      form.input :name
      form.input :email
      form.input :address
      form.input :phone
      form.input :status, as: :select, collection: Organization.statuses.keys
    end
    form.actions
  end
end
