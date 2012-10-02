require 'spec_helper'

describe Member do

  # get oauth tokens for different users
  before(:all) do
    puts "[SETUP] fetching new access tokens....."
    VCR.use_cassette "models/accounts/get_public_oauth_token", :record => :all do
      config = YAML.load_file(File.join(::Rails.root, 'config', 'databasedotcom.yml'))
      client = Databasedotcom::Client.new(config)
      @public_oauth_token = client.authenticate :username => ENV['SFDC_PUBLIC_USERNAME'], :password => ENV['SFDC_PUBLIC_PASSWORD']
    end

    VCR.use_cassette "models/accounts/get_admin_oauth_token", :record => :all do
      config = YAML.load_file(File.join(::Rails.root, 'config', 'databasedotcom.yml'))
      client = Databasedotcom::Client.new(config)
      @admin_oauth_token = client.authenticate :username => ENV['SFDC_ADMIN_USERNAME'], :password => ENV['SFDC_ADMIN_PASSWORD']
    end
  end 	

  describe "Payments" do
	  it "should return payments successfully" do
	    VCR.use_cassette "models/members/payments_success" do
	      results = Member.payments(@public_oauth_token, 'jeffdonthemic', 'id,name', 'name')
	      # should return an array
	      results.count.should >= 0
	    end
	  end
  end

  describe "Recommendations" do
	  it "should return recommendations successfully" do
	    VCR.use_cassette "models/members/recommendations_success" do
	      results = Member.recommendations(@public_oauth_token, 'jeffdonthemic', 'id,name')
	      # should return an array
	      results.count.should >= 0
	    end
	  end

	  it "should create a recommendation successfully" do
	    VCR.use_cassette "models/members/recommendations_create_success" do
	      results = Member.recommendation_create(@public_oauth_token, 'jeffdonthemic', 'mess', 'my comment')
        results[:success].should == 'true'
        results[:message].should_not be_empty
	    end
	  end	  

	  it "should return error when it cannot create a recommendation" do
	    VCR.use_cassette "models/members/recommendations_create_failure" do
	      results = Member.recommendation_create(@public_oauth_token, 'jeffdonthemic', 'mess', '')
        results[:success].should == 'false'
        results[:message].should == 'Required parameters are missing. You must pass values for the following: recommendation_for_username, recommendation_from_username, recommendation_text.'
	    end
	  end	  	  
  end  

end