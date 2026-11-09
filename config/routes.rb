Rails.application.routes.draw do
  devise_for :users,
             ActiveAdmin::Devise.config.merge(
               sign_out_via: :delete
             )
  devise_scope :user do
    post "api/v1/auth/sign_in", to: "api/v1/sessions#create", as: :api_v1_user_session
    delete "api/v1/auth/sign_out", to: "api/v1/sessions#destroy", as: :destroy_api_v1_user_session
  end
  ActiveAdmin.routes(self)
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  namespace :api do
    namespace :v1 do
      get "me", to: "users#show"
      resources :users, only: [ :index, :create ]
      resources :employees, only: [ :index, :show, :create, :update, :destroy ]
      resources :salaries, only: [ :index, :show, :create, :update, :destroy ]
      resources :salary_slips, only: [ :index, :show, :create, :update ]
    end
  end

  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  root to: redirect("/admin")
end
