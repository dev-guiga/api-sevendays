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
      resource :diary, only: [ :show ], controller: "diaries" do
        post "schedulings", to: "schedulings#create"
        patch "schedulings/:id", to: "schedulings#update"
      end
      resources :diaries, only: [ :create, :update ]
    end
  end
end
