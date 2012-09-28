CsApi::Application.routes.draw do

	namespace :v1 do

	  match "/members" => "members#index", :as => :members
	  match "/members/:membername" => "members#show", :as => :member
	  match "/members/search/:membername" => "members#search", :as => :members_search
	  match "/members/:membername/recommendations" => "members#recommendations", :as => :recommendations
	  match "/members/:membername/recommendations/create" => "members#recommendation_create", :as => :recommendation_create

		match "/accounts/authenticate" => "accounts#authenticate", :as => :authenticate, :via => :post
		match "/accounts/activate" => "accounts#activate", :as => :activate_account, :via => :post
		match "/accounts/create" => "accounts#create", :as => :create_account, :via => :post
		match "/accounts/exists" => "accounts#exists", :as => :account_exists, :via => :get
		match "/accounts/find" => "accounts#find", :as => :account_exists, :via => :get

	end  

end
