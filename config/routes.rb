# frozen_string_literal: true

#  Copyright (c) 2008-2017, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

Rails.application.routes.draw do

  get 'status/health', to: 'status#health'
  get 'status/readiness', to: 'status#readiness'

  namespace :recryptrequests do
    get 'new_ldap_password'
    post 'recrypt'
  end

  resources :teams do
    get "/:id/groups" => "legacy_routes#redirect"
    resources :api_users, only: [:index, :create, :destroy], module: 'api/team'
    resources :teammembers
    resources :groups, except: [:index] do
      resources :accounts do
        put 'move', to: 'accounts#move'
        resources :items
      end
    end
  end

  resource :login, except: :show do
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

  get 'profile', to: 'profile#index'

end
