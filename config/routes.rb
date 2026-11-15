Rails.application.routes.draw do
  root "home#index"

  resources :venues, only: [ :index ]
end
