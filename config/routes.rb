Rails.application.routes.draw do
  root "venues#index"

  resources :venues, only: [:index]
end