Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  scope path: "api" do
    devise_for :users, controllers: {
      passwords: "devise/passwords",
      sessions: "devise/sessions"
    }

    post "sign_up", to: "users#create", as: "sign_up"
  end
end
