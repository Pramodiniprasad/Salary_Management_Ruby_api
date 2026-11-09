Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins ENV.fetch("FRONTEND_ORIGIN", "http://localhost:3000")
    resource "*",
             headers: %w[Authorization Content-Type Accept],
             expose: [ "Authorization" ],
             methods: %i[get post put patch delete options head]
  end
end
