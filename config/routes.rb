CsApi::Application.routes.draw do

	namespace :v1 do

	  match "/members/search/:membername" => "members#search", :as => :members_search
		resources :members

		match "/accounts/authenticate" => "accounts#authenticate", :as => :authenticate
		match "/accounts/activate" => "accounts#activate", :as => :activate_account
		match "/accounts/create" => "accounts#create", :as => :create_account
		match "/accounts/exists" => "accounts#exists", :as => :account_exists
		match "/accounts/find" => "accounts#find", :as => :account_exists

	end  

end
