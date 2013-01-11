require 'spec_helper'

describe Challenge do

  # get oauth tokens for different users
  before(:all) do
		VCR.use_cassette "shared/public_oauth_token", :record => :all do
		  @public_oauth_token = SfdcHelper.public_access_token
		end

  	VCR.use_cassette "models/challenge/create_rspec_challenge" do
	  	json = JSON.parse(File.read("spec/data/create_challenge.json"))
	  	results = Challenge.create(@public_oauth_token, json)
	  	# set the challnege we can test with
	  	@challenge_id = results[:challenge_id]
	  	puts "[SETUP] Created challenge #{@challenge_id} for rspec testing"
	  end    

	  # update the challenge with
  	VCR.use_cassette "models/challenge/update_rspec_challenge" do
	  	json = JSON.parse(File.read("spec/data/update_challenge_rspec.json"))
	  	results = Challenge.update(@public_oauth_token, @challenge_id, json)
	  	puts "[SETUP] Updating challenge #{@challenge_id} for rspec testing: #{results[:success]}"	  	
	  end	

	  # need to add participants  
    VCR.use_cassette "models/challenge/create_rspec_participant" do
    	puts "[SETUP] Adding participants for #{@challenge_id} for rspec testing"
      results = Participant.create(@public_oauth_token, 'jeffdonthemic', 
      	@challenge_id, {'status' => 'Registered'})
    end	  

    # add a comment and a reply
  	VCR.use_cassette "models/challenge/create_rspec_comment_success" do
  		puts "[SETUP] Adding comments and reply for #{@challenge_id} for rspec testing"
	  	results = Challenge.comment(@public_oauth_token, {:membername => 'jeffdonthemic',
	  		:challenge_id => @challenge_id, :comments => 'These are my comments'})
	  	# get the reply
	  	@reply_to_rspec = results[:message]
	  end
  	VCR.use_cassette "models/challenge/create_rspec_reply_success" do
	  	results = Challenge.comment(@public_oauth_token, {:membername => 'jeffdonthemic',
	  		:challenge_id => @challenge_id, :comments => 'These are my reply', 
	  		:reply_to => @reply_to_rspec})  	
	  end		   

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
		  	# results.first.should have_key('challenge_participants__r') -- issues with sandbox
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
		  	results[:errors].count.should == 0
		  end
	  end
	  it "should return errors gracefully" do
	  	VCR.use_cassette "models/challenge/create_validation_error" do
		  	json = JSON.parse(File.read("spec/data/create_challenge_error.json"))
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

  describe "Challenge participants" do
	  it "should a collection with the correct keys" do
	  	VCR.use_cassette "models/challenge/participants" do
		  	results = Challenge.participants(@public_oauth_token, @challenge_id)
		  	results.first.should have_key('has_submission')
		  	results.first.should have_key('member')
		  	results.first.should have_key('id')
		  	results.first.should have_key('status')
		  	results.first.should have_key('challenge')
		  	results.first['member__r'].should have_key('name')
		  	results.first['member__r'].should have_key('id')
		  	results.first['member__r'].should have_key('total_wins')
		  	results.first['member__r'].should have_key('profile_pic')
		  end
	  end
  end       

  describe "Challenge comments" do
	  it "should a collection with the correct keys" do
	  	VCR.use_cassette "models/challenge/comments" do
		  	results = Challenge.comments(@public_oauth_token, @challenge_id)
		  	results.first.should have_key('comment')
		  	results.first.should have_key('member')
		  	results.first.should have_key('createddate')
		  	results.first.should have_key('id')
				results.first.should have_key('challenge')
				results.first['member__r'].should have_key('id')
				results.first['member__r'].should have_key('name')
				results.first['member__r'].should have_key('profile_pic')
				results.first['challenge_comments__r']['records'].first.should have_key('comment')
				results.first['challenge_comments__r']['records'].first.should have_key('member')
				results.first['challenge_comments__r']['records'].first.should have_key('createddate')
				results.first['challenge_comments__r']['records'].first.should have_key('id')
				results.first['challenge_comments__r']['records'].first.should have_key('reply_to')
				results.first['challenge_comments__r']['records'].first.should have_key('member')
				results.first['challenge_comments__r']['records'].first['member__r'].should have_key('name')
				results.first['challenge_comments__r']['records'].first['member__r'].should have_key('id')
				results.first['challenge_comments__r']['records'].first['member__r'].should have_key('profile_pic')
		  end
	  end
  end      

  describe "Challenge comments" do
	  it "should should create successfully" do
	  	VCR.use_cassette "models/challenge/create_comment_success" do
		  	results = Challenge.comment(@public_oauth_token, {:membername => 'jeffdonthemic',
		  		:challenge_id => @challenge_id, :comments => 'These are my comments'})
		  	results[:success].should == 'true'
		  end
	  end

	  it "should should create successfully for a reply to" do
	  	VCR.use_cassette "models/challenge/create_comment_success" do
		  	results = Challenge.comment(@public_oauth_token, {:membername => 'jeffdonthemic',
		  		:challenge_id => @challenge_id, :comments => 'These are my comments'})
		  	# get the reply
		  	@reply_to = results[:message]
		  end
	  	VCR.use_cassette "models/challenge/create_reply_success" do
		  	results = Challenge.comment(@public_oauth_token, {:membername => 'jeffdonthemic',
		  		:challenge_id => @challenge_id, :comments => 'These are my reply', 
		  		:reply_to => @reply_to})
		  	results[:success].should == 'true'		  	
		  end		  
	  end	  
  end     

end