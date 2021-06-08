# frozen_string_literal: true

Rails.application.routes.draw do
  namespace :admin do
    resources :maintenance_tasks, only: :index
    post '/maintenance_tasks/:id/execute', to: 'maintenance_tasks#execute', as: 'maintenance_tasks_execute'

    resources :users, only: [:create]

    resource :settings, only: [:index] do
      post 'update_all'
      get 'index'
    end
  end
end
