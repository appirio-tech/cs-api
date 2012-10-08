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

  describe "restricted methods without api key" do
    it "should return 401 for 'payments'" do
      request.env['oauth_token'] = @public_oauth_token
      get 'payments', 'membername' => 'jeffdonthemic'
      response.should_not be_success
    end

    it "should return 401 for 'recommendation_create'" do
      request.env['oauth_token'] = @public_oauth_token
			post 'recommendation_create', 'membername' => 'jeffdonthemic', 
				'recommendation_from_username' => 'mess', 'recommendation_text' => ''
      response.should_not be_success
    end          
  end  

	describe "'find_by_membername' jeffdonthemic" do
		it "returns http success" do
			VCR.use_cassette "controllers/v1/members/find_by_membername_jeffdonthemic" do
				request.env['oauth_token'] = @public_oauth_token
				get 'find_by_membername', 'membername' => 'jeffdonthemic'
				response.should be_success
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
				get 'search', 'keyword' => 'jeffdonthemic'
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
				get 'search', 'keyword' => 'jeffdonthemic'
				h = JSON.parse(response.body)['response'].first
				keys.each do |k|
					h.should have_key(k)
				end
			end
		end

	end

	describe "Search for unknown member" do
		it "should return no user" do
			VCR.use_cassette "controllers/v1/members/search_unknown" do
				request.env['oauth_token'] = @public_oauth_token
				get 'search', 'keyword' => 'unknown-user-999'
				response.should be_success
				h = JSON.parse(response.body)
				h['count'].should == 0
			end
		end
	end  

	describe "Recommendations" do
		it "should return recommendations successfully" do
			VCR.use_cassette "controllers/v1/members/recommendations" do
				request.env['oauth_token'] = @public_oauth_token
				get 'recommendations', 'membername' => 'jeffdonthemic'
				response.should be_success
			end
		end

		it "should return success when recommendation created successfully" do
			VCR.use_cassette "controllers/v1/members/recommendation_create_success" do
				request.env['oauth_token'] = @public_oauth_token
				request.env['Authorization'] = 'Token token="'+@api_key+'"'				
				post 'recommendation_create', 'membername' => 'jeffdonthemic', 
					'recommendation_from_username' => 'mess', 'recommendation_text' => 'My text'
				h = JSON.parse(response.body)['response']
        h['success'].should == 'true'
        h['message'].should_not be_empty				
				response.should be_success
			end
		end

		it "should return error message when recommendation is not created successfully" do
			VCR.use_cassette "controllers/v1/members/recommendation_create_failure" do
				request.env['oauth_token'] = @public_oauth_token
				request.env['Authorization'] = 'Token token="'+@api_key+'"'				
				post 'recommendation_create', 'membername' => 'jeffdonthemic', 
					'recommendation_from_username' => 'mess', 'recommendation_text' => ''
				h = JSON.parse(response.body)['response']
        h['success'].should == 'false'
        h['message'].should_not be_empty				
				response.should be_success
			end
		end		

	end  		

	describe "Payments" do
		it "should return payments successfully" do
			VCR.use_cassette "controllers/v1/members/payments" do
				request.env['oauth_token'] = @public_oauth_token
				request.env['Authorization'] = 'Token token="'+@api_key+'"'
				get 'payments', 'membername' => 'jeffdonthemic'
				response.should be_success
			end
		end
	end  	

end