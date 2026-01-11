Rails.application.routes.draw do
  devise_for :users, controllers: { registrations: 'registrations' }
  resources :tasks
  resources :messages, only: [:index, :show, :new, :create]
  resources :users, only: [:show]
  root "listings#index"
  
  # User account pages
  get "my_listings", to: "listings#my_listings", as: :my_listings
  get "my_messages", to: "messages#my_messages", as: :my_messages
  get "my_saved_ads", to: "favorites#index", as: :my_saved_ads
  
  # Vehicle registration lookup (must be before resources to avoid conflicts)
  post 'vehicle_lookup', to: 'vehicle_lookup#lookup', as: 'vehicle_lookup'
  
  # Listings with favorites
  resources :listings do
    resources :favorites, only: [:create, :destroy]
  end
  
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  # root "posts#index"
end
