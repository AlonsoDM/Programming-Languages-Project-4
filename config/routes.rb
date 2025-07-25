Rails.application.routes.draw do
  root 'dashboard#index'

  resources :products do
    member do
      patch :stock_movement
      patch :toggle_active
    end
  end

  resources :clients do
    member do
      patch :toggle_active
    end
  end

  resources :tax_rates

  resources :invoices do
    member do
      patch :send_invoice
      patch :mark_as_paid
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
