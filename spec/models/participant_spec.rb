require 'spec_helper'

describe Participant do

  # get oauth tokens for different users
  before(:all) do
    puts "[SETUP] fetching new access tokens....."
    VCR.use_cassette "models/tos/get_public_oauth_token", :record => :all do
      config = YAML.load_file(File.join(::Rails.root, 'config', 'databasedotcom.yml'))
      client = Databasedotcom::Client.new(config)
      @public_oauth_token = client.authenticate :username => ENV['SFDC_PUBLIC_USERNAME'], :password => ENV['SFDC_PUBLIC_PASSWORD']
    end

    # find a challenge is the sandbox that exists
    @challenge_id = '2'
  end 	

  describe "'create'" do
	  it "should create a participant record successfully" do
	    VCR.use_cassette "models/participants/create_success" do
	      results = Participant.create(@public_oauth_token, 'jeffdonthemic', 
	      	@challenge_id, {'status' => 'Registered'})
	      results[:success].should == 'true'
	      results[:message].should have(18).characters
	    end
	  end	  

	  it "should return an error for a non-existent challenge" do
	    VCR.use_cassette "models/participants/create_bad_challenge" do
	      results = Participant.create(@public_oauth_token, 'jeffdonthemic', 
	      	'0', {'status' => 'Registered'})
	      results[:success].should == 'false'
	      results[:message].should == 'Challenge not found for: 0'
	    end
	  end	  	

	  it "should return an error for a non-existent member" do
	    VCR.use_cassette "models/participants/create_bad_member" do
	      results = Participant.create(@public_oauth_token, 'badmember', 
	      	@challenge_id, {'status' => 'Registered'})
	      results[:success].should == 'false'
	      results[:message].should == 'Member not found for: badmember'
	    end
	  end	 	     	  
  end  	  	

  describe "'update'" do
	  it "should update a participant record successfully" do
	    VCR.use_cassette "models/participants/update_success" do
	      results = Participant.create(@public_oauth_token, 'jeffdonthemic', 
	      	@challenge_id, {'status' => 'Watching'})
	      results[:success].should == 'true'
	      results[:message].should have(18).characters
	    end
	  end	  
  end  	   

  describe "'status'" do
	  it "should return nil for a member not participating" do
	    VCR.use_cassette "models/participants/current_status_not_participating" do
	      results = Participant.status(@public_oauth_token, 'badmember', '0')
	      results.should be_nil
	    end
	  end	  

	  it "should return a valid participant with the correct keys" do
	    VCR.use_cassette "models/participants/current_status_jeffdonthemic" do
	      results = Participant.status(@public_oauth_token, 'jeffdonthemic', @challenge_id)
	      results.should have_key('challenge__r')
	      results.should have_key('name')
	      results.should have_key('has_submission')
	      results.should have_key('money_awarded')
	      results.should have_key('member__r')
	      results['member__r'].should have_key('valid_submissions')
	      results['member__r'].should have_key('name')
	      results['member__r'].should have_key('id')
	      results.should have_key('member')
	      results.should have_key('send_discussion_emails')
	      results.should have_key('status')
				results.should have_key('challenge')
	    end
	  end	  		  
  end  	

end