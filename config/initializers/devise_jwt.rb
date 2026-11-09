Devise.setup do |config|
  config.jwt do |jwt|
    jwt.secret = Rails.application.secret_key_base
    jwt.dispatch_requests = [ [ "POST", %r{^/api/v1/auth/sign_in$} ] ]
    jwt.revocation_requests = [ [ "DELETE", %r{^/api/v1/auth/sign_out$} ] ]
    jwt.expiration_time = 1.hour.to_i
    jwt.request_formats = { user: [ :json ] }
  end
end
