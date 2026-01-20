Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  post "sign_up", to: "users#create", as: "sign_up"
  post "sign_in", to: "sessions#create", as: "sign_in"
  delete "sign_out", to: "sessions#destroy", as: "sign_out"

  post "reset_password", to: "users#reset_password", as: "reset_password"
end
