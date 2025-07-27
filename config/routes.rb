Rails.application.routes.draw do
  # Devise routes for authentication
  devise_for :users, controllers: {
    omniauth_callbacks: 'users/omniauth_callbacks'
  }

  # Root route
  root 'projects#index'

  # Core application routes
  resources :projects do
    resources :tasks
    resources :files, controller: 'project_files', as: 'project_files' do
      collection do
        post :upload
        post :share
      end
      member do
        get :download
      end
    end
    resources :budgets, controller: 'project_budgets', as: 'project_budgets'
    resources :transactions, controller: 'project_transactions', as: 'project_transactions' do
      collection do
        get :summary
      end
    end
    member do
      patch :add_member
      delete :remove_member
    end
  end

  # Admin namespace
  namespace :admin do
    resources :users
    resources :projects
    root 'dashboard#index'
  end

  # API namespace for external integrations
  namespace :api do
    namespace :v1 do
      resources :projects, only: [:index, :show]
      resources :tasks, only: [:index, :show]
    end
  end

  # API Sync routes
  post 'api_sync/openproject/sync', to: 'api_sync#sync_openproject'
  post 'api_sync/openproject/export', to: 'api_sync#export_to_openproject'
  post 'api_sync/maybe/sync', to: 'api_sync#sync_maybe'
  post 'api_sync/maybe/export', to: 'api_sync#export_to_maybe'

  # E-commerce routes (Medusa integration)
  resources :products, only: [:index, :show] do
    collection do
      post :sync
    end
  end
  
  resources :carts, only: [:show] do
    member do
      post :checkout
    end
    
    collection do
      post :add_item
      patch :update_item
      delete :remove_item
    end
  end
  
  resources :orders, only: [:index, :show] do
    member do
      patch :cancel
      post :request_refund
    end
    
    collection do
      post :sync
    end
  end
  
  # Reports and Analytics
  resources :reports, only: [:index] do
    collection do
      get :project_overview
      get :project_financial
      get :project_tasks
      get :project_team
      get :export_pdf
    end
  end
  
  # User Onboarding Wizard
  get '/onboarding/start', to: 'onboarding#start', as: 'start_onboarding'
  get '/onboarding/complete', to: 'onboarding#complete', as: 'complete_onboarding'
  post '/onboarding/skip', to: 'onboarding#skip', as: 'skip_onboarding'
  get '/onboarding/:step', to: 'onboarding#show', as: 'onboarding_step'
  patch '/onboarding/:step', to: 'onboarding#update', as: 'update_onboarding_step'

  # Health check endpoint
  get '/health', to: 'application#health'
end
