Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  post "sign_up", to: "users#create", as: "sign_up"
  post "sign_in", to: "sessions#create", as: "sign_in"
  delete "sign_out", to: "sessions#destroy", as: "sign_out"

  devise_for :users, controllers: {
    passwords: "devise/passwords"
  }
end
