Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  scope path: "api" do
    post "sign_up", to: "users#create", as: "sign_up"
    get "me", to: "users#me", as: "me"

    devise_for :users, controllers: {
      passwords: "devise/passwords",
      sessions: "devise/sessions"
    }

    namespace :owner do
      post :create_diary, to: "diaries#create", as: "create_diary"
    end
  end
end
