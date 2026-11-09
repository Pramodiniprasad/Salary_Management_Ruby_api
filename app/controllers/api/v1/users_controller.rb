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
    end
  end
end
