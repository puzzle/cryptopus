Cryptopus::Application.routes.draw do
  resources :searches
  resources :recryptrequests
  resources :teams do
    resources :teammembers
    resources :groups do
      resources :accounts do
        resources :items
      end
    end
  end

  namespace :admin do
    resources :ldapsettings
    resources :users
    resources :recryptrequests
  end

  resources :login do
    collection do
      match :pwdchange
      match :login
      match :logout
      match :noaccess
      match :authenticate
    end
  end
  match '/:controller(/:action(/:id))'

  root to: 'login#login'
end

