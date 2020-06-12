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

  resources :teams, only: [:show, :index, :destroy] do
    resources :folders, only: [:show, :destroy]
  end

  resources :accounts, only: [:show, :destroy] do
    resources :file_entries, only: [:show, :destroy]
  end

  scope '/session', module: 'session' do
    get 'sso', to: 'sso#create' if AuthConfig.keycloak_enabled?
    get 'sso/inactive', to: 'sso#inactive' if AuthConfig.keycloak_enabled?
    post 'local', to: 'local#create'
    get 'local', to: 'local#new'
  end

  get 'session/new', to: 'session#new'
  post 'session', to: 'session#create'
  get 'session/destroy', to: 'session#destroy'
  get 'session/show_update_password', to: 'session#show_update_password'
  post 'session/update_password', to: 'session#update_password'
  post 'session/locale', to: 'session#changelocale'

  get 'wizard', to: 'wizard#index'
  post 'wizard/apply'

  get 'search', to: 'search#index'

  root to: 'search#index'

  get 'changelog', to: 'changelog#index'

  get 'profile', to: 'profile#index'

end
