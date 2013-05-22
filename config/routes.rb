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
    resources :recryptrequests do
      collection do
        post :resetpassword
      end
    end
  end

  resource :login do
    get :login
    get :pwdchange
    post :pwdchange
    get :logout
    get :noaccess
    post :authenticate
    post :changelocale
  end
  match '/:controller(/:action(/:id))'

  root to: 'logins#login'
end

