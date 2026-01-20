Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  post "sign_up", to: "users#create", as: "sign_up"
  post "sign_in", to: "sessions#create", as: "sign_in"
end
