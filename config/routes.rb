# frozen_string_literal: true

#  Copyright (c) 2008-2017, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

Rails.application.routes.draw do

  root 'frontend#index'

  get 'status/health', to: 'status#health'
  get 'status/readiness', to: 'status#readiness'

  namespace :recrypt do
    get 'ldap', to: 'ldap#new'
    post 'ldap', to: 'ldap#create'
    if AuthConfig.oicd_enabled?
      get 'oicd', to: 'oicd#new'
      post 'oicd', to: 'oicd#create'
    end
  end

  scope '/session', module: 'session' do
    if AuthConfig.keycloak_enabled?
      get 'sso', to: 'sso#create'
      get 'sso/inactive', to: 'sso#inactive'
    end
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

  get 'changelog', to: 'changelog#index'

  get 'profile', to: 'profile#index'

end
