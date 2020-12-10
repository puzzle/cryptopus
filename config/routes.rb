# frozen_string_literal: true

Rails.application.routes.draw do

  root 'frontend#index'

  get 'status/health', to: 'status#health'
  get 'status/readiness', to: 'status#readiness'

  namespace :recrypt do
    if AuthConfig.ldap_enabled?
      get 'ldap', to: 'ldap#new'
      post 'ldap', to: 'ldap#create'
    end
    if AuthConfig.oidc_enabled?
      get 'oidc', to: 'oidc#new'
      post 'oidc', to: 'oidc#create'
    end
  end

  scope '/session', module: 'session' do
    if AuthConfig.oidc_enabled?
      get 'oidc', to: 'oidc#create'
    end
    post 'local', to: 'local#create'
    get 'local', to: 'local#new', as: 'session_local_new'
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
