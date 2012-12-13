require 'spec_helper'

describe Deliverable do

  # get oauth tokens for different users
  before(:all) do
    puts "[SETUP] fetching new access tokens....."
    VCR.use_cassette "shared/public_oauth_token", :record => :all do
      config = YAML.load_file(File.join(::Rails.root, 'config', 'databasedotcom.yml'))
      client = Databasedotcom::Client.new(config)
      @public_oauth_token = client.authenticate :username => ENV['SFDC_PUBLIC_USERNAME'], :password => ENV['SFDC_PUBLIC_PASSWORD']
      puts "[SETUP] using access token #{@public_oauth_token}"
    end

    # find a challenge is the sandbox that exists
    @challenge_id = '58'
  end 	

  describe "'create'" do
	  it "should create a deliverable record successfully" do
	    VCR.use_cassette "models/deliverables/create_success" do
	      results = Deliverable.create(@public_oauth_token, 'jeffdonthemic', 
	      	@challenge_id, {'type' => 'Code', 'url' => 'http://www.google.com'})
	      results[:success].should == 'Unknown'
	      # results[:message].should have(18).characters
	    end
	  end	  
	end

end