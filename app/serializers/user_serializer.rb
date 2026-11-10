class UserSerializer
  def initialize(user)
    @user = user
  end

  def as_json(*)
    {
      id: @user.id,
      name: @user.name,
      email: @user.email,
      role: @user.role,
      status: @user.status,
      organization_id: @user.organization_id,
      organization: @user.organization && { name: @user.organization.name }
    }
  end
end
