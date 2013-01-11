require 'spec_helper'

describe Deliverable do

  # get oauth tokens for different users
  before(:all) do
    VCR.use_cassette "shared/public_oauth_token", :record => :all do
      @public_oauth_token = SfdcHelper.public_access_token
    end

    restforce_client = Restforce.new :oauth_token => @public_oauth_token,
      :instance_url  => ENV['SFDC_INSTANCE_URL']    

    # find a challenge with a participant
    VCR.use_cassette "models/deliverables/participant" do
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

  describe "'all'" do
    it "should return at least one record with the right keys" do
      VCR.use_cassette "models/deliverables/all" do
        results = Deliverable.all(@public_oauth_token, @membername, @challenge_id)
        results.first.should have_key('id')
        results.first.should have_key('type')
        results.first.should have_key('comments')
        results.first.should have_key('username')
        results.first.should have_key('password')
        results.first.should have_key('language')
        results.first.should have_key('url')
        results.first.should have_key('hosting_platform')
      end
    end 
  end  

  describe "'create'" do
	  it "should create a code deliverable record successfully" do
	    VCR.use_cassette "models/deliverables/create_code_success" do
	      results = Deliverable.create(@public_oauth_token, @membername, 
	      	@challenge_id, {'type' => 'Code', 'url' => 'http://www.google.com',
            'hosting_platform' => 'Heroku', 'language' => 'Java'})
	      results[:success].should == true
	      results[:message].should have(18).characters
	    end
	  end	  

    it "should return a validation error when required code fields are missing" do
      VCR.use_cassette "models/deliverables/create_code_error" do
        results = Deliverable.create(@public_oauth_token, @membername, 
          @challenge_id, {'type' => 'Code', 'url' => 'http://www.google.com'})
        results[:success].should == false
        results[:message].should == 'FIELD_CUSTOM_VALIDATION_EXCEPTION: Hosting platform is required for Code deliverables.'
      end
    end       

    it "should create a non-code deliverable record successfully" do
      VCR.use_cassette "models/deliverables/create_non_code_success" do
        results = Deliverable.create(@public_oauth_token, @membername, 
          @challenge_id, {'type' => 'Demo URL', 'url' => 'http://www.google.com'})
        results[:success].should == true
        results[:message].should have(18).characters
      end
    end   

	end

  describe "'update'" do
    it "should update a record successfully" do
      VCR.use_cassette "models/deliverables/update_success" do
        results = Deliverable.update(@public_oauth_token,
          {'type' => 'Code', 'url' => 'http://www.google.com',
            'hosting_platform' => 'Heroku', 'language' => 'Java', 
            'Id' => @deliverable_id})
        results[:success].should == true
      end
    end   

    it "should return a validation error from salesforce correctly" do
      VCR.use_cassette "models/deliverables/update_validation_error" do
        results = Deliverable.update(@public_oauth_token, 
          {'type' => 'Code', 'url' => 'http://www.google.com',
            'hosting_platform' => 'Heroku', 'language' => nil, 'Id' => @deliverable_id})
        results[:success].should == false
        results[:message].should == 'FIELD_CUSTOM_VALIDATION_EXCEPTION: Language is required for Code deliverables.'
      end
    end   
  end  

end