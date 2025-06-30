Rails.application.routes.draw do
  root 'dashboard#index'

  resources :products do
    member do
      patch :stock_movement
    end
  end

  resources :clients
  resources :tax_rates

  resources :invoices do
    member do
      patch :send_invoice
      get :pdf
    end
  end

  # API routes for AJAX calls
  namespace :api do
    namespace :v1 do
      resources :products, only: [:show]
    end
  end
end
