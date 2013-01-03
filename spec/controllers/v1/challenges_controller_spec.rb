require 'spec_helper'

describe V1::ChallengesController do

  # create a new api_key so all methods can use it
  before(:all) do
    VCR.use_cassette "shared/public_oauth_token", :record => :all do
      config = YAML.load_file(File.join(::Rails.root, 'config', 'databasedotcom.yml'))
      client = Databasedotcom::Client.new(config)
      @public_oauth_token = client.authenticate :username => ENV['SFDC_PUBLIC_USERNAME'], 
        :password => ENV['SFDC_PUBLIC_PASSWORD']
    end

    ApiKey.create!
    @api_key = ApiKey.first.access_key

    @challenge_id = '8'
  end  

  describe "methods without api key" do
    it "should return 401 for 'update'" do
      request.env['oauth_token'] = @public_oauth_token
      put 'update', 'challenge_id' => @challenge_id
      response.response_code.should == 401
    end

    it "should return 401 for 'create'" do
      request.env['oauth_token'] = @public_oauth_token
      post 'create', params = { :name => 'some name' }
      response.response_code.should == 401
    end       
  end

  describe "'open' challenges" do
    it "should be successful" do
      VCR.use_cassette "controllers/v1/challenges/open" do
        request.env['oauth_token'] = @public_oauth_token
        get 'open'
        response.should be_success
      end
    end 
  end     

  describe "'closed' challenges" do
    it "should be successful" do
      VCR.use_cassette "controllers/v1/challenges/closed" do
        request.env['oauth_token'] = @public_oauth_token
        get 'closed'
        response.should be_success
      end
    end 
  end    

  describe "'recent' challenges" do
    it "should be successful" do
      VCR.use_cassette "controllers/v1/challenges/recent" do
        request.env['oauth_token'] = @public_oauth_token
        get 'recent'
        response.should be_success
      end
    end 
  end     

  describe "'find' a challenge" do
    it "should return the correct challenge" do
      VCR.use_cassette "controllers/v1/challenges/find_success" do
        request.env['oauth_token'] = @public_oauth_token
        get 'find', 'challenge_id' => @challenge_id
        response.should be_success
        h = JSON.parse(response.body)['response']
        h['challenge_id'].should == @challenge_id
      end
    end 

    it "should return 404 for a non-existent challenges" do
      VCR.use_cassette "controllers/v1/challenges/find_non_exist" do
        request.env['oauth_token'] = @public_oauth_token
        get 'find', 'challenge_id' => '12345678'
        response.response_code.should == 404
      end
    end 

  end      

  describe "'comments'" do
    it "should be successful" do
      VCR.use_cassette "controllers/v1/challenges/comments" do
        request.env['oauth_token'] = @public_oauth_token
        get 'comments', 'challenge_id' => @challenge_id
        response.should be_success
      end
    end 
  end     

  describe "'participants'" do
    it "should be successful" do
      VCR.use_cassette "controllers/v1/challenges/participants" do
        request.env['oauth_token'] = @public_oauth_token
        get 'participants', 'challenge_id' => @challenge_id
        response.should be_success
      end
    end 
  end     

  describe "'update'" do
    it "should update the challenge successfully" do
      VCR.use_cassette "controllers/v1/challenges/update_success" do
        request.env['oauth_token'] = @public_oauth_token
        request.env['Authorization'] = 'Token token="'+@api_key+'"'     
        put 'update', 'challenge_id' => @challenge_id, 'data' =>
        {"challenge" => { "detail" => { "name" => "RSpec Challenge" } } }
        response.should be_success
        h = JSON.parse(response.body)['response']
        h['success'].should == true
        h['challenge_id'].should == @challenge_id
        h['errors'].count.should == 0
      end
    end 
  end   

  describe "'create'" do
    it "should create a challenge successfully" do
      VCR.use_cassette "controllers/v1/challenges/create_success" do
        request.env['oauth_token'] = @public_oauth_token
        request.env['Authorization'] = 'Token token="'+@api_key+'"' 
        json = JSON.parse(File.read("spec/data/create_challenge.json"))    
        post 'create', 'data' => json
        response.should be_success
        h = JSON.parse(response.body)['response']
        h['success'].should == true
        h['challenge_id'].to_i.should be_a_kind_of(Numeric)
        h['errors'].count.should == 0 
      end
    end 
  end     

end
