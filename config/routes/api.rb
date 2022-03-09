# frozen_string_literal: true

Rails.application.routes.draw do
  namespace :api do

    get 'env_settings', to: 'env_settings#index'

    resource :profile, only: [:update] do
      collection do
        patch :password, to: 'profile/password#update'
      end
    end

    resources :encryptables, except: [:new, :edit] do
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

    scope '/admin', module: 'admin' do
      resources :users, only: [:index, :update, :create, :destroy] do
        member do
          patch :role, to: 'users/role#update'
          delete :lock, to: 'users/lock#destroy'
        end
      end

      resources :settings, only: [:index, :update]

      resources :ldap_connection_test, only: ['new']
    end
    
    resources :folders, only: [:show]

    # INFO don't mix scopes and resources in routes
    resources :teams, except: [:new, :edit]  do
      resources :folders, except: [:new, :edit]
      resources :api_users, only: [:create, :destroy, :index], module: 'teams'
      resources :members, except: [:new, :edit], module: 'teams'
      resource :favourite, only: [:create, :destroy], module: 'teams', controller: 'favourite'
      resources :candidates, only:[:index], module: 'teams'
    end
  end
end
