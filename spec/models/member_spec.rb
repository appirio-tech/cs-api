require 'spec_helper'

describe Member do

  # get oauth tokens for different users
  before(:all) do
		VCR.use_cassette "shared/public_oauth_token", :record => :all do
		  @public_oauth_token = SfdcHelper.public_access_token
		end

		VCR.use_cassette "shared/admin_oauth_token", :record => :all do
		  @admin_oauth_token = SfdcHelper.admin_access_token
		end
  end 	

  describe "all" do
	  it "should return members successfully" do
	    VCR.use_cassette "models/members/all_members" do
	      results = Member.all(@public_oauth_token, 'id,name', 'name', 25, 0)
	      # should return an array
	      results.count.should > 0
	    end
	  end
  end  

  describe "search" do
	  it "should return jeffdonthemic successfully" do
	    VCR.use_cassette "models/members/search_jeffdonthemic" do
	      results = Member.search(@public_oauth_token, 'jeffdonthemic', 'id,name')
	      # should return an array
	      results.count.should > 0
	      results.first['name'].should == 'jeffdonthemic'
	    end
	  end

	  it "should not return a non-existent member" do
	    VCR.use_cassette "models/members/search_unknown" do
	      results = Member.search(@public_oauth_token, 'novaliduser', 'id,name')
	      # should return an array
	      results.count.should == 0
	    end
	  end	  
  end  

  describe "challenges" do
	  it "should return challenges successfully for a member" do
	    VCR.use_cassette "models/members/challenges_jeffdonthemic" do
	      results = Member.challenges(@public_oauth_token, 'jeffdonthemic')
	      # should return an array
	      results.count.should > 0
	    end
	  end
	  it "should not return challenges successfully for a non-existent member" do
	    VCR.use_cassette "models/members/challenges_novaliduser" do
	      results = Member.challenges(@public_oauth_token, 'novaliduser')
	      # should return an array
	      results.count.should == 0
	    end
	  end	  
  end    

  describe "find by membername" do
	  it "should return jeffdonthemc" do
	    VCR.use_cassette "models/members/find_jeffdonthemic" do
	      results = Member.find_by_membername(@public_oauth_token, 'jeffdonthemic', 'id,name')
	      # should return an array
	      results.count.should == 1
	      results.first.should have_key('name')
	      results.first.should have_key('id')
	      results.first['name'].should == 'jeffdonthemic'
	    end
	  end
	  it "should not return a non-existent member" do
	    VCR.use_cassette "models/members/find_novaliduser" do
	      results = Member.find_by_membername(@public_oauth_token, 'novaliduser', 'id,name')
	      # should return an array
	      results.count.should == 0
	    end
	  end	  
  end    

  describe "update member" do
	  it "should update successfully" do
	    VCR.use_cassette "models/members/update_success" do
	      results = Member.update(@public_oauth_token, 'jeffdonthemic', {'Jabber__c' => 'somejabbername'})
        results[:success].should == 'true'
	    end
	    # make sure it was updated successfully
	    VCR.use_cassette "models/members/update_success_check" do
        results2 = Member.find_by_membername(@public_oauth_token, 'jeffdonthemic', 'jabber__c')
        results2.first['jabber'].should == 'somejabbername'
	    end
	  end
	  it "should not update successfully with a bad field" do
	    VCR.use_cassette "models/members/update_failure" do
	      results = Member.update(@public_oauth_token, 'jeffdonthemic', {'Email__c' => 'bademail'})
        results[:success].should == 'false'
        results[:message].should == 'Email: invalid email address: bademail'
	    end
	  end
	  it "should not update successfully an unknown" do
	    VCR.use_cassette "models/members/update_failure_unknown" do
	      results = Member.update(@public_oauth_token, 'badrspecuser', {'Email__c' => 'bademail'})
        results[:success].should == 'false'
        results[:message].should == 'Member not found for: badrspecuser'
	    end
	  end	  
  end  

  describe "payments" do
	  it "should return payments successfully" do
	    VCR.use_cassette "models/members/payments_success" do
	      results = Member.payments(@public_oauth_token, 
	      	'jeffdonthemic', 'id,name', 'name')
	      # should return an array
	      results.count.should >= 0
	      results.first.should have_key('name')
	      results.first.should have_key('id')	      
	    end
	  end
  end

  describe "referrals" do
	  it "should return referrals with the corret keys" do
	    VCR.use_cassette "models/members/referrals_success" do
	      results = Member.referrals(@public_oauth_token, 
	      	'jeffdonthemic')
	      results.count.should >= 0
	      results.first.should have_key('signup_date')
	      results.first.should have_key('referral_money')	
	      results.first.should have_key('referral_id')	
	      results.first.should have_key('membername')	
	      results.first.should have_key('first_year_money')	      
	    end
	  end
  end  

  describe "recommendations" do
	  it "should return recommendations successfully" do
	    VCR.use_cassette "models/members/recommendations_success" do
	      results = Member.recommendations(@public_oauth_token, 'jeffdonthemic', 'id,name')
	      # should return an array
	      results.count.should >= 0
	      results.first.should have_key('name')
	      results.first.should have_key('id')	      
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

  describe "get member id" do
	  it "should return the correct member id for jeffdonthemic" do
	    VCR.use_cassette "models/members/member_id_jeffdonthemic" do
	      results = Member.salesforce_member_id(@public_oauth_token, 'jeffdonthemic')
	      results.should_not be_nil     
	    end
	  end  	  
	  it "should return the nil for a member that does not exist" do
	    VCR.use_cassette "models/members/member_id_badmember" do
	      expect { Member.salesforce_member_id(@public_oauth_token, 'idonotexist') }.to raise_error
	    end
	  end  		  
  end  

  describe "get salesforce user id" do
	  it "should return the correct user id for jeffdonthemic" do
	    VCR.use_cassette "models/members/user_id_jeffdonthemic" do
	      results = Member.salesforce_user_id(@public_oauth_token, 'jeffdonthemic')
	      results.should_not be_nil     
	    end
	  end  	  
	  it "should return the nil for a member that does not exist" do
	    VCR.use_cassette "models/members/user_id_badmember" do
	    	expect { Member.salesforce_user_id(@public_oauth_token, 'idonotexist') }.to raise_error
	    end
	  end  		  
  end    

end