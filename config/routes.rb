# encoding: utf-8

#  Copyright (c) 2008-2017, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

Rails.application.routes.draw do
  
  scope "(:locale)", locale: /en|de|fr|zh|ru|ch_be/ do
    namespace :recryptrequests do
      get 'new_ldap_password'
      post 'recrypt'
    end
    
    resources :teams do
      resources :teammembers
      resources :groups do
        resources :accounts do
          put 'move', to: 'accounts#move'
          resources :items
        end
      end
    end

    namespace :admin do
      resources :maintenance_tasks, only: :index
      get '/maintenance_tasks/:id/prepare', to: 'maintenance_tasks#prepare', as: 'maintenance_tasks_prepare'
      post '/maintenance_tasks/:id/execute', to: 'maintenance_tasks#execute', as: 'maintenance_tasks_execute'

      resource :settings do
        post 'update_all'
        get 'index'
      end

      resources :users, except: :destroy do
        member do
          get 'unlock'
        end
      end
      resources :recryptrequests do
        collection do
          post 'resetpassword'
        end
      end
    end

    resource :login do
      get 'login'
      get 'show_update_password'
      post 'update_password'
      get 'logout'
      get 'noaccess'
      post 'authenticate'
      post 'changelocale'
    end

    get 'wizard', to: 'wizard#index'
    post 'wizard/apply'

    get 'search', to: 'search#index'
    
    root to: 'search#index'
    
    get 'changelog', to: 'changelog#index'
  end

  scope '/api', module: 'api' do
    scope '/search', module: 'search' do
      get :accounts
      get :groups
      get :teams
    end
    scope '/admin', module: 'admin' do
      resources :users, only: :destroy do
        patch :update_role, to: '/api/admin/users#update_role'
      end
    end

    # INFO don't mix scopes and resources in routes
    resources :teams, only: [:destroy, :index]  do
      collection do
        get :last_teammember_teams
      end
      resources :groups, only: ['index'], module: 'team' do
        resources :accounts, only: ['show'], module: 'group'
      end
      resources :members, except: [:new, :edit], module: 'team' do
        collection do
          get :candidates
        end
      end
    end 
  end
end
