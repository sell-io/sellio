Rails.application.routes.draw do
  root "listings#index"

  devise_for :users, controllers: {
    registrations: 'registrations',
    sessions: 'users/sessions'
  }
  resources :messages, only: [:index, :show, :new, :create]
  resources :users, only: [:show] do
    resources :reviews, only: [:create]
    member do
      post :follow
      delete :unfollow
    end
  end

  # Static pages (footer and info)
  get "how-it-works", to: "pages#how_it_works", as: :how_it_works
  get "help", to: "pages#help_center", as: :help_center
  get "contact", to: "pages#contact", as: :contact
  get "safety-tips", to: "pages#safety_tips", as: :safety_tips
  get "faqs", to: "pages#faqs", as: :faqs
  get "privacy", to: "pages#privacy_policy", as: :privacy_policy
  get "terms", to: "pages#terms_of_service", as: :terms_of_service
  get "cookies", to: "pages#cookie_policy", as: :cookie_policy
  get "community-guidelines", to: "pages#community_guidelines", as: :community_guidelines

  get "sitemap.xml", to: "sitemap#show", as: :sitemap, defaults: { format: "xml" }

  # Payments (Stripe payment links – MVP)
  get "payment-success", to: "payments#success", as: :payment_success
  get "boost_listing/:listing_id", to: "payments#redirect_boost", as: :boost_listing
  get "verified_seller", to: "payments#redirect_verified", as: :verified_seller

  # User account pages
  get "my_listings", to: "listings#my_listings", as: :my_listings
  get "my_messages", to: "messages#my_messages", as: :my_messages
  delete "delete_conversation", to: "messages#delete_conversation", as: :delete_conversation
  get "my_saved_ads", to: "favorites#index", as: :my_saved_ads
  
  # Vehicle registration lookup (must be before resources to avoid conflicts)
  post 'vehicle_lookup', to: 'vehicle_lookup#lookup', as: 'vehicle_lookup'
  
  # Listings with favorites
  resources :listings do
    resources :favorites, only: [:create, :destroy]
    resources :offers, only: [:new, :create]
    member do
      post :mark_as_sold
      post :mark_available
    end
  end

  resources :offers, only: [:index] do
    member do
      post :accept
      post :reject
      post :counter
      post :withdraw
    end
  end

  resources :reports, only: [:new, :create]
  resources :saved_searches, only: [:index, :create, :destroy]
  get "my_saved_searches", to: "saved_searches#index", as: :my_saved_searches

  # Admin
  namespace :admin do
    root to: "dashboard#index"
    resources :users, only: [:index, :destroy] do
      member do
        post :ban
        post :unban
        post :toggle_verified
      end
    end
    resources :listings, only: [:index, :destroy]
    resources :reports, only: [:index, :show] do
      member do
        post :resolve
      end
    end
  end
  
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Branded error pages (see config.exceptions_app in config/application.rb)
  match "/404", to: "errors#not_found", via: :all
  match "/422", to: "errors#unprocessable_entity", via: :all
  match "/500", to: "errors#internal_server_error", via: :all

  # Render dynamic PWA files from app/views/pwa/*
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  resource :push_subscription, only: [:create, :destroy], controller: "push_subscriptions"

  # Defines the root path route ("/")
  # root "posts#index"
end
