Rails.application.routes.draw do
  resource :session
  resource :registration, only: %i[ new create ]
  resources :passwords, param: :token

  root "tournaments#index"

  resources :competitors

  resources :tournaments do
    member { get :live }
    resources :divisions, shallow: true do
      scope module: :divisions do
        resource :bracket, only: :create, controller: "bracket"
        resources :registrations, only: [ :index, :create, :update, :destroy ], shallow: false
        resources :team_entries, shallow: true
        resources :pools, shallow: true do
          collection { post :generate }
        end
      end
    end
    resources :courts, shallow: true, only: [ :index, :new, :create, :show, :edit, :update, :destroy ] do
      member { get :live }
      resource :scorer, only: :show, controller: "court_scorer" do
        post :start
      end
    end
  end

  resources :team_entries, only: [] do
    resources :memberships, only: [ :create, :destroy ]
  end

  resources :pools, only: [] do
    scope module: :pools do
      resources :registrations, only: [ :index, :create, :update, :destroy ]
    end
  end

  resources :matches, only: [ :show, :edit, :update ] do
    member { post :finalize }
    resource :lineup, only: [ :edit, :update ]
    resources :bouts, only: [ :create, :update, :destroy ] do
      resources :ippons, only: [ :create, :destroy ]
    end
    resources :ippons, only: [ :create, :destroy ]
  end

  get "up" => "rails/health#show", as: :rails_health_check
end
