require 'spec_helper'
require 'leaderboard'

describe Leaderboard do

  # get oauth tokens for different users
  before(:all) do
    VCR.use_cassette "shared/public_oauth_token", :record => :all do
      @public_oauth_token = SfdcHelper.public_access_token
    end
  end  	

  describe "public leaderboard" do
    it "should return the correct keys and rank" do
      VCR.use_cassette "lib/leaderboard/return_success" do
        results = Leaderboard.public(@public_oauth_token).first
        results.should have_key('total_money')
        results.should have_key('wins')
        results.should have_key('country')
        results.should have_key('active')
        results.should have_key('profile_pic')
        results.should have_key('username')
        results.should have_key('rank')
        results['rank'].should == 1
      end
    end
  end	

end