require 'spec_helper'

describe Category do

  # get oauth tokens for different users
  before(:all) do
		VCR.use_cassette "shared/public_oauth_token", :record => :all do
		  @public_oauth_token = SfdcHelper.public_access_token
		end
	end

  describe "all categories" do
	  it "should return an array of categories" do
	    VCR.use_cassette "models/categories/list" do
	      results = Category.all(@public_oauth_token)
	      results.count.should > 0
	    end
	  end
  end  	

  describe "a category" do
	  it "should have the correct keys" do
	    VCR.use_cassette "models/categories/list" do
	      results = Category.all(@public_oauth_token)
	      results.first.should have_key('name')
	      results.first.should have_key('color')
	    end
	  end
  end  	  

end