CsApi::Application.routes.draw do

	namespace :v1 do

	  match "/members" => "members#index", :as => :members, :via => :get
	  match "/members/search" => "members#search", :as => :members_search	  
	  match "/members/:membername" => "members#find_by_membername", :as => :member, :via => :get
	  match "/members/:membername/payments" => "members#payments", :as => :members_payments, :via => :get
	  match "/members/:membername/recommendations" => "members#recommendations", :as => :recommendations, :via => :get
	  match "/members/:membername/recommendations/create" => "members#recommendation_create", :as => :recommendation_create, :via => :post

		match "/accounts/authenticate" => "accounts#authenticate", :as => :authenticate, :via => :post
		match "/accounts/activate/:membername" => "accounts#activate", :as => :activate_account, :via => :get
		match "/accounts/create" => "accounts#create", :as => :create_account, :via => :post
		match "/accounts/find_by_service" => "accounts#find_by_service", :as => :account_exists, :via => :get
		match "/accounts/reset_password/:membername" => "accounts#reset_password", :as => :account_reset_password, :via => :get
		match "/accounts/update_password/:membername" => "accounts#update_password", :as => :account_update_password, :via => :put

	end  

	root :to => redirect("http://www.cloudspokes.com")

end
