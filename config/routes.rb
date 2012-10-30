CsApi::Application.routes.draw do

	namespace :v1 do

	  match "/members" => "members#index", :via => :get
	  match "/members/search" => "members#search", :via => :get 
		match "/members/:membername/challenges" => "members#challenges", :via => :get	  
	  match "/members/:membername/payments" => "members#payments", :via => :get
	  match "/members/:membername/recommendations" => "members#recommendations", :via => :get
	  match "/members/:membername/recommendations/create" => "members#recommendation_create", :via => :post
	  match "/members/:membername" => "members#find_by_membername", :via => :get	
	  match "/members/:membername/update" => "members#update", :via => :put  

		match "/accounts/authenticate" => "accounts#authenticate", :via => :post
		match "/accounts/activate/:membername" => "accounts#activate", :via => :get
		match "/accounts/create" => "accounts#create", :via => :post
		match "/accounts/find_by_service" => "accounts#find_by_service", :via => :get
		match "/accounts/reset_password/:membername" => "accounts#reset_password", :via => :get
		match "/accounts/update_password/:membername" => "accounts#update_password", :via => :put

	  match "/leaderboard" => "leaderboard#index", :via => :get		

	end  

	root :to => redirect("http://www.cloudspokes.com")

end
