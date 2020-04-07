# frozen_string_literal: true

Rails.application.routes.draw do
  scope '/api', module: 'api' do

    resources :groups, only: [:index]
    resources :teams, only: [:index]
    resources :accounts, only: [:show, :index, :update]

    resources :api_users do
      member do
        get :token, to: 'api_users/token#show'
        delete :token, to: 'api_users/token#destroy'
        post :lock, to: 'api_users/lock#create'
        delete :lock, to: 'api_users/lock#destroy'
      end
    end

    resources :accounts, only: [:show]
    scope '/search', module: 'search' do
      get :accounts
      get :groups
      get :teams
    end

    scope '/admin', module: 'admin' do
      resources :users, only: :destroy do
        member do
          patch :update_role, to: 'users/role#update'
        end
      end
      resources :ldap_connection_test, only: ['new']
    end

    resources :accounts, only: ['show']

    # INFO don't mix scopes and resources in routes
    resources :teams, only: [:destroy, :index]  do
      collection do
        get :last_teammember_teams
      end
      resources :groups, only: ['index'], module: 'team'
      resources :members, except: [:new, :edit], module: 'team' do
        collection do
          get :candidates
        end
      end
    end
  end
end
