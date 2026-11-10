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

      def pagination_parameters
        page = Integer(params.fetch(:page, 1).to_s, 10)
        per_page = Integer(params.fetch(:per_page, 50).to_s, 10)

        unless page.between?(1, 1_000_000) && per_page.between?(1, 100)
          raise ArgumentError
        end

        [ page, per_page ]
      rescue ArgumentError
        render json: {
          error: "bad_request",
          details: "page must be between 1 and 1000000; per_page must be between 1 and 100."
        }, status: :bad_request
      end

      def paginated_response(scope, page:, per_page:, serializer:)
        records = scope.offset((page - 1) * per_page).limit(per_page + 1).to_a
        has_next_page = records.length > per_page
        records = records.first(per_page)

        render json: {
          data: records.map { |record| serializer.new(record).as_json },
          meta: {
            page: page,
            per_page: per_page,
            next_page: has_next_page ? page + 1 : nil
          }
        }
      end
    end
  end
end
