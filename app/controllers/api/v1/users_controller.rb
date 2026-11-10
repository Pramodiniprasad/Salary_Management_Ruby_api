module Api
  module V1
    class UsersController < BaseController
      def index
        authorize User, :index?
        users = policy_scope(User).order(:id)
        render json: { data: users.map { |user| UserSerializer.new(user).as_json } }
      end

      def show
        authorize current_user, :show?
        render json: { data: UserSerializer.new(current_user).as_json }
      end

      def update
        authorize current_user, :update?
        attributes = profile_params
        password_attributes = attributes.slice(:current_password, :password, :password_confirmation)

        if password_attributes.values.any?(&:present?)
          update_password(attributes, password_attributes)
        elsif current_user.update(attributes.except(:current_password, :password, :password_confirmation))
          render json: { data: UserSerializer.new(current_user).as_json }
        else
          render_validation_errors(current_user)
        end
      end

      def create
        @user = User.new(user_params)
        @user.organization = current_user.organization
        authorize @user, :create?

        if @user.save
          render json: { data: UserSerializer.new(@user).as_json }, status: :created
        else
          render_validation_errors(@user)
        end
      end

      private

      def user_params
        params.require(:user).permit(:name, :email, :password, :password_confirmation, :role)
      end

      def profile_params
        params.require(:user).permit(
          :name, :email, :current_password, :password, :password_confirmation
        )
      end

      def update_password(attributes, password_attributes)
        current_user.errors.clear
        current_user.errors.add(:current_password, :blank) if password_attributes[:current_password].blank?
        current_user.errors.add(:password, :blank) if password_attributes[:password].blank?
        current_user.errors.add(:password_confirmation, :blank) if password_attributes[:password_confirmation].blank?

        if current_user.errors.any?
          render_validation_errors(current_user)
        elsif current_user.update_with_password(attributes)
          render json: { data: UserSerializer.new(current_user).as_json }
        else
          render_validation_errors(current_user)
        end
      end
    end
  end
end
