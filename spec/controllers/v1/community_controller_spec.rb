require 'spec_helper'

describe V1::CommunitiesController do

  # create a new api_key so all methods can use it
  before(:all) do
    VCR.use_cassette "shared/public_oauth_token", :record => :all do
      @public_oauth_token = SfdcHelper.public_access_token
    end
  end  

  describe "all communities" do
    it "should return correctly" do
      VCR.use_cassette "controllers/v1/community/all" do
        request.env['oauth_token'] = @public_oauth_token
        get 'all'
        response.should be_success
      end
    end       
  end

  describe "find community" do
    it "should return correctly" do
      VCR.use_cassette "controllers/v1/community/find" do
        request.env['oauth_token'] = @public_oauth_token
        get 'find', 'community_id' => 'public'
        response.should be_success
      end
    end       
  end  

end