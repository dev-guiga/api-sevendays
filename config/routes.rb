Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  scope path: "api" do
    resources :users, only: [ :create ]
    resource :user, only: [ :show ]

    devise_for :users, skip: [ :registrations ], controllers: {
      passwords: "devise/passwords",
      sessions: "devise/sessions"
    }

    namespace :owner do
      resource :diary, only: [ :create, :show, :update ], controller: "diaries" do
        resources :schedulings, only: [ :create, :update, :destroy ]
      end
    end
  end
end
