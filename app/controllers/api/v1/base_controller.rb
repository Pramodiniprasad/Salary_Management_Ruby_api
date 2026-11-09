module Api
  module V1
    class BaseController < ActionController::API
      include Devise::Controllers::Helpers
      include Pundit::Authorization

      before_action :authenticate_user!
      before_action :ensure_active_account

      rescue_from Pundit::NotAuthorizedError do
        render json: { error: "forbidden" }, status: :forbidden
      end

      rescue_from ActiveRecord::RecordNotFound do
        render json: { error: "not_found" }, status: :not_found
      end

      rescue_from ActionController::ParameterMissing do |error|
        render json: { error: "bad_request", details: error.message }, status: :bad_request
      end

      private

      def ensure_active_account
        return if current_user&.active_for_authentication?

        render json: { error: "account_inactive" }, status: :forbidden
      end

      def render_validation_errors(record)
        render json: { errors: record.errors.to_hash }, status: :unprocessable_entity
      end
    end
  end
end
