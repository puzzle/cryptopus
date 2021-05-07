# frozen_string_literal: true

Rails.application.routes.draw do
  namespace :api do

    resources :all_folders, only: [:index]

    get 'env_settings', to: 'env_settings#index'

    patch 'locale', to: 'locale#update'

    resources :accounts, except: [:new, :edit] do
      resources :file_entries, only: [:create, :index, :destroy, :show]
    end

    resources :api_users, except: [:new, :edit] do
      member do
        get :token, to: 'api_users/token#show'
        delete :token, to: 'api_users/token#destroy'
        get :ccli_token, to: 'api_users/ccli_token#show'
        post :lock, to: 'api_users/lock#create'
        delete :lock, to: 'api_users/lock#destroy'
      end
    end

    scope '/search', module: 'search', as: 'search' do
      get :accounts
      get :folders
      get :teams
    end

    scope '/admin', module: 'admin' do
      resources :users, only: [:index, :destroy] do
        member do
          patch :update_role, to: 'users/role#update'
        end
      end

      resource :settings, only: [:index] do
        post 'update_all'
        get 'index'
      end

      resources :ldap_connection_test, only: ['new']
    end
    
    resources :folders, only: [:show]

    # INFO don't mix scopes and resources in routes
    resources :teams, except: [:new, :edit]  do

      collection do
        resources :last_member_teams, only: [:index], module: 'teams'
      end

      resources :folders, except: [:new, :edit]
      resources :api_users, only: [:create, :destroy, :index], module: 'teams'
      resources :members, except: [:new, :edit], module: 'teams'
      resource :favourite, only: [:create, :destroy], module: 'teams', controller: 'favourite'
      resources :candidates, only:[:index], module: 'teams'
    end
  end
end
