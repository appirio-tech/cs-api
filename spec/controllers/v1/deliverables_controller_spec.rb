require 'spec_helper'

describe V1::DeliverablesController do

  # create a new api_key so all methods can use it
  before(:all) do
  
    VCR.use_cassette "shared/public_oauth_token", :record => :all do
      @public_oauth_token = SfdcHelper.public_access_token
    end

    ApiKey.create!
    @api_key = ApiKey.first.access_key

    restforce_client = Restforce.new :oauth_token => @public_oauth_token,
      :instance_url  => ENV['SFDC_INSTANCE_URL']    

    # find a challenge with a participant
    VCR.use_cassette "controllers/v1/deliverables/challenge" do
      participant = restforce_client.query("select challenge__r.challenge_id__c, 
        member__r.name from challenge_participant__c limit 1").first 
      @challenge_id = participant['Challenge__r']['Challenge_Id__c']
      @membername = participant['Member__r']['Name']  
      puts "[SETUP] Challenge Id: #{@challenge_id}"
      puts "[SETUP] Membername: #{@membername}"
    end

    # find a deliverable to update
    VCR.use_cassette "models/deliverables/deliverable_id" do   
      @deliverable_id = restforce_client.query("select id from submission_deliverable__c 
        limit 1").first['Id']  
      puts "[SETUP] Running updates with deliverable #{@deliverable_id}"
    end    

  end  

  describe "methods without api key" do
    it "should return 401 for 'all'" do
      request.env['oauth_token'] = @public_oauth_token
      get 'all', 'challenge_id' => @challenge_id, 'membername' => @membername
      response.response_code.should == 401
    end

    it "should return 401 for 'create'" do
      request.env['oauth_token'] = @public_oauth_token
      put 'update', 'challenge_id' => @challenge_id, 'membername' => @membername
      response.response_code.should == 401
    end    

    it "should return 401 for 'update'" do
      request.env['oauth_token'] = @public_oauth_token
      post 'create', 'challenge_id' => @challenge_id, 'membername' => @membername
      response.response_code.should == 401
    end
         
  end  

  describe "'all' deliverables" do
    it "should be successful" do
      VCR.use_cassette "controllers/v1/deliverables/all" do
        request.env['oauth_token'] = @public_oauth_token
        request.env['Authorization'] = 'Token token="'+@api_key+'"'
        get 'all', 'challenge_id' => @challenge_id, 'membername' => @membername
        h = JSON.parse(response.body)['response']
        response.should be_success
      end
    end 
  end    

  describe "'create' deliverable" do
    it "should be successful" do
      VCR.use_cassette "controllers/v1/deliverables/create", :record => :new_episodes do
        request.env['oauth_token'] = @public_oauth_token
        request.env['Authorization'] = 'Token token="'+@api_key+'"'
        post 'create', 'challenge_id' => @challenge_id, 'membername' => @membername,
        'data' => {'type' => 'Demo URL', 'url' => 'http://www.google.com'}
        response.should be_success
      end
    end 
  end  

  describe "'update' deliverable" do
    it "should be successful" do
      VCR.use_cassette "controllers/v1/deliverables/create", :record => :new_episodes do
        request.env['oauth_token'] = @public_oauth_token
        request.env['Authorization'] = 'Token token="'+@api_key+'"'
        put 'update', 'challenge_id' => @challenge_id, 'membername' => @membername,
        'data' => {'type' => 'Demo URL', 'url' => 'http://www.google.com',
          'Id' => @deliverable_id}
        response.should be_success
      end
    end 
  end     


end
