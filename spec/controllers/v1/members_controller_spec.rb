require 'spec_helper'

describe V1::MembersController do

  # create a new api_key so all methods can use it
  before(:all) do
    VCR.use_cassette "controllers/v1/accounts/get_public_oauth_token", :record => :all do
      config = YAML.load_file(File.join(::Rails.root, 'config', 'databasedotcom.yml'))
      client = Databasedotcom::Client.new(config)
      @public_oauth_token = client.authenticate :username => ENV['SFDC_PUBLIC_USERNAME'], :password => ENV['SFDC_PUBLIC_PASSWORD']
    end

    ApiKey.create!
    @api_key = ApiKey.first.access_key
  end  	

	describe "'show' jeffdonthemic" do
		it "returns http success" do
			VCR.use_cassette "controllers/v1/members/show_jeffdonthemic" do
				request.env['oauth_token'] = @public_oauth_token
				get 'show', 'id' => 'jeffdonthemic'
				response.should be_success
			end
		end

		it "should have the correct internal hash keys" do
			VCR.use_cassette "controllers/v1/members/show_jeffdonthemic" do
				request.env['oauth_token'] = @public_oauth_token
				get 'show', 'id' => 'jeffdonthemic'
				h = JSON.parse(response.body)['response']
				%w{member challenges recommendations}.each do |k|
					h.should have_key(k)
				end
			end
		end

		it "should have the correct member hash keys" do
			VCR.use_cassette "controllers/v1/members/show_jeffdonthemic" do
				keys = %w{ valid_submissions total_2nd_place total_1st_place total_public_money total_points name challenges_entered time_zone id total_wins total_3st_place profile_pic }
				request.env['oauth_token'] = @public_oauth_token
				get 'show', 'id' => 'jeffdonthemic'
				h = JSON.parse(response.body)['response']['member']
				keys.each do |k|
					h.should have_key(k)
				end
			end
		end  

		it "should have the correct challenge hash keys" do
			VCR.use_cassette "controllers/v1/members/show_jeffdonthemic" do
				keys = %w{ prize_type total_prize_money end_date challenge_categories__r name top_prize challenge_id challenge_type id start_date description status }
				request.env['oauth_token'] = @public_oauth_token
				get 'show', 'id' => 'jeffdonthemic'
				h = JSON.parse(response.body)['response']['challenges'].first
				keys.each do |k|
					h.should have_key(k)
				end
			end
		end 

		it "should have the correct recommendation hash keys" do
			VCR.use_cassette "controllers/v1/members/show_jeffdonthemic" do
				keys = %w{ member recommendation createddate id recommendation_from recommendation_from__r }
				request.env['oauth_token'] = @public_oauth_token
				get 'show', 'id' => 'jeffdonthemic'
				h = JSON.parse(response.body)['response']['recommendations'].first
				keys.each do |k|
					h.should have_key(k)
				end
			end
		end

	end

	describe "GET 'index'" do
		it "returns http success" do
			VCR.use_cassette "controllers/v1/members/all_members" do
				request.env['oauth_token'] = @public_oauth_token
				get 'index'
				response.should be_success
				h = JSON.parse(response.body)
				h['count'].should > 0
			end
		end
	end

	describe "'search' for jeffdonthemic" do
		it "returns jeffdonthemic" do
			VCR.use_cassette "controllers/v1/members/search_jeffdonthemic" do
				request.env['oauth_token'] = @public_oauth_token
				get 'search', 'membername' => 'jeffdonthemic'
				h = JSON.parse(response.body)
				h['response'].first['name'].should == 'jeffdonthemic'
				h['count'].should > 0
			end
		end

		it "should have all of the correct keys" do
			VCR.use_cassette "controllers/v1/members/search_jeffdonthemic" do
				# keys that should exist in the returned json
				keys = %w{name challenges_entered total_2nd_place active_challenges total_1st_place id total_wins summary_bio total_public_money total_3st_place profile_pic}
				request.env['oauth_token'] = @public_oauth_token
				get 'search', 'membername' => 'jeffdonthemic'
				h = JSON.parse(response.body)['response'].first
				keys.each do |k|
					h.should have_key(k)
				end
			end
		end

	end

	describe "Search for unknown member" do
		it "returns no user" do
			VCR.use_cassette "controllers/v1/members/search_unknown" do
				request.env['oauth_token'] = @public_oauth_token
				get 'search', 'membername' => 'unknown-user-999'
				response.should be_success
				h = JSON.parse(response.body)
				h['count'].should == 0
			end
		end
	end  

end