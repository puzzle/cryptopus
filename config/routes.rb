# frozen_string_literal: true

Rails.application.routes.draw do

  root 'frontend#index'

  get 'status/health', to: 'status#health'
  get 'status/readiness', to: 'status#readiness'

  namespace :session do
    post '', action: :create
    post 'local', to: 'local#create'
    get 'local', to: 'local#new'

    get 'new'
    get 'destroy'
    get 'show_update_password'
    post 'update_password'

    if AuthConfig.oidc_enabled?
      get 'oidc', to: 'oidc#create'
    end
  end

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

  get 'changelog', to: 'changelog#index'

end
