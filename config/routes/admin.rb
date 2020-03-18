# frozen_string_literal: true

Rails.application.routes.draw do
  namespace :admin do
    resources :maintenance_tasks, only: :index
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

    get  'teams', to: 'teams#index'
  end
end
