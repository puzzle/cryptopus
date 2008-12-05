ActionController::Routing::Routes.draw do |map|
  map.root :controller => 'login', :action => 'login'

  map.resources :teams do |team|

    team.resources :teammembers
    team.resources :groups do |group|
      
      group.resources :accounts do |account|
        
        account.resources :items

      end
    end
  end

  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
end
