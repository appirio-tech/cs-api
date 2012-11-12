require 'spec_helper'

describe Challenge do

  # get oauth tokens for different users
  before(:all) do
    puts "[SETUP] fetching new access tokens....."
    VCR.use_cassette "models/challenge/get_public_oauth_token", :record => :all do
      config = YAML.load_file(File.join(::Rails.root, 'config', 'databasedotcom.yml'))
      client = Databasedotcom::Client.new(config)
      @public_oauth_token = client.authenticate :username => ENV['SFDC_PUBLIC_USERNAME'], :password => ENV['SFDC_PUBLIC_PASSWORD']
    end

    @challenge_id = '8'
  end 

  describe "'Open' challenges" do
	  it "should return challenge that are open" do
	  	VCR.use_cassette "models/challenge/all_open" do
		  	results = Challenge.all(@public_oauth_token, true, nil, 'name')
		  	results.first.should have_key('name')
		  	results.first.should have_key('total_prize_money')
		  	results.first.should have_key('end_date')
		  	results.first.should have_key('challenge_id')
		  	results.first.should have_key('id')
		  	results.first.should have_key('registered_members')
		  	results.first.should have_key('challenge_type')
		  	results.first.should have_key('is_open')
		  	results.first.should have_key('start_date')
		  	results.first.should have_key('description')
		  	results.first.should have_key('days_till_close')
		  	results.first.should have_key('challenge_categories__r')
		  	results.first['challenge_categories__r']['records'].first.should have_key('display_name')
		  end
	  end
  end      

  describe "'Recent' challenges" do
	  it "should return more than one" do
	  	VCR.use_cassette "models/challenge/recent" do
		  	results = Challenge.recent(@public_oauth_token)
		  	results.first.should have_key('name')
		  	results.first.should have_key('total_prize_money')
		  	results.first.should have_key('end_date')
		  	results.first.should have_key('top_prize')
		  	results.first.should have_key('challenge_id')
		  	results.first.should have_key('id')
		  	results.first.should have_key('description')
		  	results.first.should have_key('challenge_participants__r')
		  	results.first.should have_key('challenge_categories__r')
		  end
	  end
  end    

  describe "'Find' a challenge" do
	  it "should return the correct challenge with correct keys" do
	  	VCR.use_cassette "models/challenge/find" do
		  	results = Challenge.find(@public_oauth_token, @challenge_id)
		  	results.should have_key('discussion_board')
		  	results.should have_key('prize_type')
		  	results.should have_key('total_prize_money')
		  	results.should have_key('end_date')
		  	results.should have_key('registered_members')
		  	results.should have_key('terms_of_service')
		  	results.should have_key('submissions')
		  	results.should have_key('name')
		  	results.should have_key('top_prize')
		  	results.should have_key('challenge_id')
		  	results.should have_key('challenge_type')
		  	results.should have_key('submission_details')
		  	results.should have_key('id')
		  	results.should have_key('winner_announced')
		  	results.should have_key('description')
		  	results.should have_key('is_open')
		  	results.should have_key('start_date')
		  	results.should have_key('requirements')
		  	results.should have_key('release_to_open_source')
		  	results.should have_key('status')
		  	results['challenge_categories__r']['records'].first.should have_key('name')
		  	results['challenge_prizes__r']['records'].first.should have_key('place')
		  	results['challenge_prizes__r']['records'].first.should have_key('prize')
		  	results['terms_of_service__r'].should have_key('default_tos')
		  	results['terms_of_service__r'].should have_key('id')
		  	results['challenge_id'].should == @challenge_id
		  end
	  end
  end  	    	

  describe "Creating a challenge" do
	  it "should create a challenge successfully" do
	  	VCR.use_cassette "models/challenge/create" do
		  	json = JSON.parse(File.read("spec/data/create_challenge.json"))
		  	results = Challenge.create(@public_oauth_token, json)
		  	results[:success].should == true
		  	results[:challengeId].to_i.should be_a_kind_of(Numeric)
		  end
	  end
	  it "should return errors gracefully" do
	  	VCR.use_cassette "models/challenge/create_validation_error" do
		  	json = JSON.parse(File.read("spec/data/create_challenge.json"))
		  	results = Challenge.create(@public_oauth_token, json)
		  	results[:success].should == false
		  	results[:challengeId].should be_nil
		  	results[:errors].count.should >= 0
		  	puts results
		  end
	  end
  end  	  

  describe "Updating a challenge" do
	  it "should update a challenge successfully" do
	  	VCR.use_cassette "models/challenge/update" do
		  	json = JSON.parse(File.read("spec/data/update_challenge.json"))
		  	results = Challenge.update(@public_oauth_token, @challenge_id, json)
		  	results[:success].should == true
		  	results[:challengeId].to_i.should be_a_kind_of(Numeric)
		  end
	  end
  end  	    

end