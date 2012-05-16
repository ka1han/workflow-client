WorkFlowEngineOnRails::Application.routes.draw do
  get "login/index"

  get "authentication_console/new"
  get "authentication_console/edit"
  get "authentication_console/delete"

  resources :ticket_mappings
  resources :ticket_rules

  match "nsc_configs/destroy" => "nsc_configs#destroy"
  match "staged_tickets/update" => "staged_tickets#update"
  match "main/get_log" => "main#get_log"
  match 'staged_tickets' => 'staged_tickets#index'
  match 'ticket_configs/show' => 'ticket_configs#show'
  match 'ticket_configs/new/:wsdl_file_name' => 'ticket_configs#new'
  match 'integer_property/edit' => 'integer_property#edit'
  match 'integer_property/update' => 'integer_property#update'
  match 'integer_property' => 'integer_property#index'
  match 'authentication_console' => 'authentication_console#index'
  match 'authentication_console/new' => 'authentication_console#new'
  match 'authentication_console/edit' => 'authentication_console#edit'
  match 'authentication_console/delete' => 'authentication_console#delete'

  match 'login' => 'login#index'
  match 'login/index' => 'login#index'

  resources :modules
  resources :added_modules
  resources :jira3_ticket_configs
  resources :jira4_ticket_configs

  resources :ticket_configs
  resources :nsc_configs
  resources :main
  resources :authentication_consoles, :path => 'authentication_console'

  get 'ticket_configs/:destroy/:id' => 'ticket_configs#destroy'


  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match ' products/:id ' => ' catalog #view'
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
  # just remember to delete public/index.html.haml.old.
  root :to => "main#index"

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id(.:format)))'
end
