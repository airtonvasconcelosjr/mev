Rails.application.routes.draw do
  # Root is the summary/home page
  root "home#index"

  # Sessions / Auth
  get "login", to: "sessions#new", as: :login
  post "login", to: "sessions#create"
  delete "logout", to: "sessions#destroy", as: :logout

  # Banking features
  get "balances/index", as: :balances
  get "statements/index", as: :statements
  get "receipts/:id", to: "receipts#show", as: :receipt

  # Manual Debts
  resources :debts, only: [ :index, :create, :destroy ]

  # Other default routes
  get "up" => "rails/health#show", as: :rails_health_check
end
