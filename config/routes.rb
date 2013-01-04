CsApi::Application.routes.draw do

	namespace :v1 do

		# members
	  match "/members" => "members#index", :via => :get
	  match "/members/search" => "members#search", :via => :get 
		match "/members/:membername/challenges" => "members#challenges", :via => :get	  
		match "/members/:membername/challenges_as_admin" => "members#challenges_as_admin", :via => :get	  		
	  match "/members/:membername/payments" => "members#payments", :via => :get
	  match "/members/:membername/referrals" => "members#referrals", :via => :get
	  match "/members/:membername/recommendations" => "members#recommendations", :via => :get
	  match "/members/:membername/recommendations/create" => "members#recommendation_create", :via => :post
	  match "/members/:membername" => "members#find_by_membername", :via => :get	
	  match "/members/:membername" => "members#update", :via => :put  

	  # accounts
		match "/accounts/authenticate" => "accounts#authenticate", :via => :post
		match "/accounts/activate/:membername" => "accounts#activate", :via => :get
		match "/accounts/disable/:membername" => "accounts#disable", :via => :get		
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
		match "/challenges/:challenge_id/comment" => "challenges#comment", :via => :post	

		# participants
		match "/participants/:membername/:challenge_id" => "participants#current_status", :via => :get
		match "/participants/:membername/:challenge_id" => "participants#create", :via => :post		
		match "/participants/:membername/:challenge_id" => "participants#update", :via => :put
		match "/participants/:membername/:challenge_id/deliverables" => "deliverables#all", :via => :get
		match "/participants/:membername/:challenge_id/deliverable" => "deliverables#create", :via => :post
		match "/participants/:membername/:challenge_id/deliverable" => "deliverables#update", :via => :put

		# private messages
		match "/messages" => "private_messages#create", :via => :post		
		match "/messages/:id" => "private_messages#find", :via => :get
		match "/messages/:id" => "private_messages#update", :via => :put
		match "/messages/:id/reply" => "private_messages#reply", :via => :post
		match "/messages/inbox/:membername" => "private_messages#inbox", :via => :get			
		match "/messages/to/:membername" => "private_messages#to", :via => :get	
		match "/messages/from/:membername" => "private_messages#from", :via => :get				

		# squirrelforce
		match "/squirrelforce/reserve_server" => "squirrelforce#reserve_server", :via => :get
		match "/squirrelforce/release_server" => "squirrelforce#release_server", :via => :get
		match "/squirrelforce/unleash_squirrel/:submission_deliverable_id" => "squirrelforce#unleash_squirrel", :via => :get

		# judging
		match "/judging" => "judging#queue", :via => :get
		match "/judging/add" => "judging#add", :via => :post

		# communities
		match "/communities" => "communities#all", :via => :get
		match "/communities/:community_id" => "communities#find", :via => :get	
		match "/communities/add_member" => "communities#add_member", :via => :post		

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
