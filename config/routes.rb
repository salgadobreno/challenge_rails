require 'sidekiq/web'

Rails.application.routes.draw do
  mount Sidekiq::Web => '/sidekiq'
  resources :products
  resource :cart do
    post "add_item" => "carts#add_item"
    delete ":product_id" => "carts#remove_item"
  end
  get "up" => "rails/health#show", as: :rails_health_check

  root "rails/health#show"
end
