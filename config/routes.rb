Digg::Application.routes.draw do
  resources :redishashes do
    member do
      post "save_redis_value"
      get "destroy_redis_value"
      get "add_redis_value"
    end
  end

  resources :stringlists

  resources :objecteds do
    member do
      get "destroy_redis_value"
      get "add_redis_value"
    end
  end

  resources :records do
    member do
      post "save_redis_value"
      get "edit_redis_value"
      get "destroy_redis_value"
      get "add_redis_value"
    end
  end

  resources :products do
    member do
      post "save_redis_value"
      get "edit_redis_value"
      get "destroy_redis_value"
      get "add_redis_value"
    end
  end

  resources :redis_infos do
    collection do
      get "export"
      get "import"
      get 'index'
      get 'graph'
      get 'terminal'
      post 'configuration'
      get 'load_redis'
    end
  end

  resources :twitters do
    collection do
      get "init_data"
      get "index"
      get "remove_friend"
      get "add_post"
      get "add_friend"
    end
  end

  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  root :to => 'redis_infos#index'

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id))(.:format)'
end
