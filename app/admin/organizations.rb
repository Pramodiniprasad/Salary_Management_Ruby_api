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
