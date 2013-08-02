CsApi::Application.routes.draw do

  namespace :v1 do

    # members
    match "/members" => "members#index", :via => :get
    match "/members/search" => "members#search", :via => :get 
    match "/members/:membername/challenges" => "members#challenges", :via => :get
    match "/members/:membername/challenges/past" => "members#past_challenges", :via => :get   	  		
    match "/members/:membername/payments" => "members#payments", :via => :get
    match "/members/:membername/referrals" => "members#referrals", :via => :get
    match "/members/:membername/recommendations" => "members#recommendations", :via => :get
    match "/members/:membername/recommendations/create" => "members#recommendation_create", :via => :post
    match "/members/:membername/login_type" => "members#login_type", :via => :get
    match "/members/:membername" => "members#find_by_membername", :via => :get	
    match "/members/:membername" => "members#update", :via => :put  

    # accounts
    match "/accounts/authenticate" => "accounts#authenticate", :via => :post
    match "/accounts/activate/:membername" => "accounts#activate", :via => :get
    match "/accounts/disable/:membername" => "accounts#disable", :via => :get		
    match "/accounts/create" => "accounts#create", :via => :post
    match "/accounts/find_by_service" => "accounts#find_by_service", :via => :get
    match "/accounts/whois" => "accounts#whois", :via => :get		
    match "/accounts/:membername" => "accounts#find", :via => :get
    match "/accounts/reset_password/:membername" => "accounts#reset_password", :via => :get # deprecated
    match "/accounts/update_password/:membername" => "accounts#update_password", :via => :put # deprecated
    match "/accounts/update_password_token/:membername" => "accounts#update_password_token", :via => :put
    match "/accounts/change_password_with_token/:membername" => "accounts#change_password_with_token", :via => :put
    match "/accounts/:membername/referred_by" => "accounts#referred_by", :via => :put
    match "/accounts/:membername/marketing" => "accounts#apply_marketing_info", :via => :put

    #preferences
    match "/preferences/:membername" => "preferences#all", :via => :get
    match "/preferences/:membername" => "preferences#update", :via => :post

    # challenges	
    match "/challenges" => "challenges#all", :open => 'true', :via => :get
    match "/challenges" => "challenges#create", :via => :post		
    match "/challenges/closed" => "challenges#all", :open => 'false', :via => :get
    match "/challenges/recent" => "challenges#recent", :via => :get
    match "/challenges/advsearch" => "challenges#advsearch", :via => :get		
    match "/challenges/search" => "challenges#search", :via => :get
    match "/challenges/:challenge_id" => "challenges#find", :via => :get
    match "/challenges/:challenge_id" => "challenges#update", :via => :put		
    match "/challenges/:challenge_id/comments" => "challenges#comments", :via => :get
    match "/challenges/:challenge_id/participants" => "challenges#participants", :via => :get
    match "/challenges/:challenge_id/scorecards" => "challenges#scorecards", :via => :get
    match "/challenges/:challenge_id/scorecard" => "challenges#scorecard", :via => :get		
    match "/challenges/:challenge_id/submission_deliverables" => "challenges#submission_deliverables", :via => :get
    match "/challenges/:challenge_id/survey" => "challenges#survey", :via => :post
    match "/challenges/:challenge_id/comment" => "challenges#comment", :via => :post
    match "/challenges/:challenge_id/admin" => "challenges#find", :admin => true, :via => :get	

    # participants
    match "/participants/:participant_id" => "participants#find", :via => :get
    match "/participants/:membername/:challenge_id" => "participants#current_status", :via => :get
    match "/participants/:membername/:challenge_id" => "participants#create", :via => :post		
    match "/participants/:membername/:challenge_id" => "participants#update", :via => :put
    match "/participants/:membername/:challenge_id/deliverables" => "deliverables#all", :via => :get
    match "/participants/:membername/:challenge_id/deliverable" => "deliverables#create", :via => :post
    match "/participants/:membername/:challenge_id/deliverable" => "deliverables#update", :via => :put

    # temp.. these will go away with new submissions functionality
    match "/participants/:membername/:challenge_id/current_submssions" => "deliverables#current_submssions", :via => :get
    match "/participants/:membername/:challenge_id/delete_submission_url_file" => "deliverables#delete_submission_url_file", :via => :get
    match "/participants/:membername/:challenge_id/submission_url_file" => "deliverables#submission_url_file", :via => :post
    match "/participants/:membername/:challenge_id/submission/:submission_id" => "deliverables#find", :via => :get

    # private messages
    match "/messages" => "private_messages#create", :via => :post		
    match "/messages/:id" => "private_messages#find", :via => :get
    match "/messages/:id" => "private_messages#update", :via => :put
    match "/messages/:id/reply" => "private_messages#reply", :via => :post
    match "/messages/inbox/:membername" => "private_messages#inbox", :via => :get			
    match "/messages/to/:membername" => "private_messages#to", :via => :get	
    match "/messages/from/:membername" => "private_messages#from", :via => :get				

    # judging
    match "/judging" => "judging#queue", :via => :get
    match "/judging/add" => "judging#add", :via => :post
    match "/judging/outstanding/:membername" => "judging#outstanding_scorecards_by_member", :via => :get
    match "/judging/scorecard/:id" => "judging#find_scorecard_by_participant", :via => :get
    match "/judging/scorecard/:id" => "judging#save_scorecard_for_participant", :via => :put

    # communities
    match "/communities" => "communities#all", :via => :get
    match "/communities/:community_id" => "communities#find", :via => :get	
    match "/communities/add_member" => "communities#add_member", :via => :post		

    # leaderboard
    match "/leaderboard" => "leaderboard#public", :via => :get
    match "/leaderboard_all" => "leaderboard#public_all", :via => :get
    match "/leaderboard/referral" => "leaderboard#referral", :via => :get

    # platform metadata
    match "/stats" => "metadata#stats", :via => :get
    match "/platforms" => "metadata#platforms", :via => :get    
    match "/technologies" => "metadata#technologies", :via => :get          
    match "/categories" => "metadata#categories", :via => :get
    match "/metadata/participant" => "metadata#participant", :via => :get

    match "/tos" => "tos#all", :via => :get		
    match "/tos/:id" => "tos#find", :via => :get		

  end  

  root :to => redirect("http://iodocs.cloudspokes.com/")

  mount_sextant if Rails.env.development? # https://github.com/schneems/sextant

end
