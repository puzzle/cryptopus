# frozen_string_literal: true

Rails.application.routes.draw do
  namespace :admin do

    resources :users, only: [:create]

    resource :settings, only: [:index] do
      post 'update_all'
      get 'index'
    end
  end
end
