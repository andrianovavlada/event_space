Rails.application.routes.draw do
  root "home#index"

  resources :venues, only: [ :index, :show ] do
    resource :favorite, only: [ :create, :destroy ]
  end
  resources :favorites, only: :index
  get "/my-bookings", to: "bookings#index", as: :my_bookings

  get "/signup", to: "registrations#new", as: :signup
  post "/signup", to: "registrations#create"

  get "/login", to: "sessions#new", as: :login
  post "/login", to: "sessions#create"

  delete "/logout", to: "sessions#destroy", as: :logout
end
