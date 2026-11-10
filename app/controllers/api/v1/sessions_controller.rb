module Api
  module V1
    class SessionsController < Devise::SessionsController
      respond_to :html, :json
      skip_before_action :verify_authenticity_token, if: :json_request?

      private

      def json_request?
        request.format.json?
      end

      def respond_with(resource, _opts = {})
        return super unless request.format.json?

        render json: { data: UserSerializer.new(resource).as_json }, status: :ok
      end

      def respond_to_on_destroy(options = {})
        if request.format.json?
          render json: { message: "Signed out" }, status: :ok
        else
          super(options)
        end
      end
    end
  end
end
