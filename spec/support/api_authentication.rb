module ApiAuthentication
  def api_headers_for(user)
    post "/api/v1/auth/sign_in",
         params: { user: { email: user.email, password: "password123" } },
         as: :json

    expect(response).to have_http_status(:ok)
    token = response.headers.fetch("Authorization")
    { "Authorization" => token, "Accept" => "application/json" }
  end
end

RSpec.configure do |config|
  config.include ApiAuthentication, type: :request
end
