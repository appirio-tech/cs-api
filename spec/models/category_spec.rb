require 'spec_helper'

describe Category do

  # get oauth tokens for different users
  before(:all) do
		VCR.use_cassette "shared/public_oauth_token", :record => :all do
		  @public_oauth_token = SfdcHelper.public_access_token
		end
	end

  describe "all categories" do
	  it "should return an array of strings" do
	    VCR.use_cassette "models/categories/list" do
	      results = Category.all(@public_oauth_token)
	      puts "===== results #{results}"
	      results.count.should > 0
	    end
	  end
  end  		  

end