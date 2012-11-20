CsApi::Application.routes.draw do

	namespace :v1 do

		# members
	  match "/members" => "members#index", :via => :get
	  match "/members/search" => "members#search", :via => :get 
		match "/members/:membername/challenges" => "members#challenges", :via => :get	  
	  match "/members/:membername/payments" => "members#payments", :via => :get
	  match "/members/:membername/recommendations" => "members#recommendations", :via => :get
	  match "/members/:membername/recommendations/create" => "members#recommendation_create", :via => :post
	  match "/members/:membername" => "members#find_by_membername", :via => :get	
	  match "/members/:membername" => "members#update", :via => :put  

	  # accounts
		match "/accounts/authenticate" => "accounts#authenticate", :via => :post
		match "/accounts/activate/:membername" => "accounts#activate", :via => :get
		match "/accounts/create" => "accounts#create", :via => :post
		match "/accounts/find_by_service" => "accounts#find_by_service", :via => :get
		match "/accounts/reset_password/:membername" => "accounts#reset_password", :via => :get
		match "/accounts/update_password/:membername" => "accounts#update_password", :via => :put

		# challenges	
		match "/challenges" => "challenges#open", :via => :get
		match "/challenges" => "challenges#create", :via => :post		
		match "/challenges/closed" => "challenges#closed", :via => :get
		match "/challenges/recent" => "challenges#recent", :via => :get
		match "/challenges/:challenge_id" => "challenges#find", :via => :get
		match "/challenges/:challenge_id" => "challenges#update", :via => :put		
		match "/challenges/:challenge_id/comments" => "challenges#comments", :via => :get
		match "/challenges/:challenge_id/participants" => "challenges#participants", :via => :get
		match "/challenges/:challenge_id/survey" => "challenges#survey", :via => :post	

		# participants
		match "/participants/:membername/:challenge_id" => "participants#current_status", :via => :get
		match "/participants/:membername/:challenge_id" => "participants#create", :via => :post		
		match "/participants/:membername/:challenge_id" => "participants#update", :via => :put	

		# leaderboard
	  match "/leaderboard" => "leaderboard#public", :via => :get
	  # stats
	  match "/stats" => "stats#public", :via => :get
	  # misc
	  match "/categories" => "categories#all", :via => :get	
	  match "/tos" => "tos#all", :via => :get		
	  match "/tos/:id" => "tos#find", :via => :get		

	end  

	root :to => redirect("http://www.cloudspokes.com")

end
