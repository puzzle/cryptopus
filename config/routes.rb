ActionController::Routing::Routes.draw do |map|
  map.root :controller => 'login', :action => 'login'

  # Normal application paths for all users
  map.resources :search
  map.resources :recryptrequests
  map.resources :teams do |team|

    team.resources :teammembers
    team.resources :groups do |group|
      
      group.resources :accounts do |account|
        
        account.resources :items

      end
    end
  end

  # Admin section paths for root and users
  # with the administrator flag
  map.namespace :admin do |admin|
    
    admin.resources :ldapsettings
    admin.resources :users
    admin.resources :recryptrequests

  end

  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
end
