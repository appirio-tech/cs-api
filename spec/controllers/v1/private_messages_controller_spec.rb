require 'spec_helper'

describe V1::PrivateMessagesController do

  # create a new api_key so all methods can use it
  before(:all) do
    VCR.use_cassette "shared/public_oauth_token", :record => :all do
      @public_oauth_token = SfdcHelper.public_access_token
    end

    ApiKey.create!
    @api_key = ApiKey.first.access_key
  end  

  describe "methods without api key" do
    it "should return 401 for 'find'" do
      request.env['oauth_token'] = @public_oauth_token
      get 'find', 'id' => '1'
      response.response_code.should == 401
    end
   it "should return 401 for 'to'" do
      request.env['oauth_token'] = @public_oauth_token
      get 'to', 'membername' => 'jeffdonthemic'
      response.response_code.should == 401
    end
   
   it "should return 401 for 'from'" do
      request.env['oauth_token'] = @public_oauth_token
      get 'from', 'membername' => 'jeffdonthemic'
      response.response_code.should == 401
    end
   it "should return 401 for 'inbox'" do
      request.env['oauth_token'] = @public_oauth_token
      get 'inbox', 'membername' => 'jeffdonthemic'
      response.response_code.should == 401
    end
   it "should return 401 for 'create'" do
      request.env['oauth_token'] = @public_oauth_token
      post 'create', 'membername' => 'jeffdonthemic'
      response.response_code.should == 401
    end
   it "should return 401 for 'update'" do
      request.env['oauth_token'] = @public_oauth_token
      put 'update', 'id' => '1', 'data' => 'jeffdonthemic'
      response.response_code.should == 401
    end
    it "should return 401 for 'reply'" do
      request.env['oauth_token'] = @public_oauth_token
      post 'reply', 'id' => '1', 'data' => 'jeffdonthemic'
      response.response_code.should == 401
    end
  end

  describe "methods with api key" do
    it "should return 200 for 'find'" do
      VCR.use_cassette "controllers/v1/private_messages/all_for_find" do
        results = PrivateMessage.to(@public_oauth_token, 'jeffdonthemic')
        @message_id = results.first.id
      end
      VCR.use_cassette "controllers/v1/private_messages/find_with_key" do
        request.env['oauth_token'] = @public_oauth_token
        request.env['Authorization'] = 'Token token="'+@api_key+'"'
        get 'find', 'id' => @message_id
        response.response_code.should == 200
      end
    end  
    it "should return 200 for 'to'" do
      VCR.use_cassette "controllers/v1/private_messages/to_with_key" do
        request.env['oauth_token'] = @public_oauth_token
        request.env['Authorization'] = 'Token token="'+@api_key+'"'
        get 'to', 'membername' => 'jeffdonthemic'
        response.response_code.should == 200
      end
    end 
    it "should return 200 for 'to'" do
      VCR.use_cassette "controllers/v1/private_messages/from_with_key" do
        request.env['oauth_token'] = @public_oauth_token
        request.env['Authorization'] = 'Token token="'+@api_key+'"'
        get 'from', 'membername' => 'jeffdonthemic'
        response.response_code.should == 200
      end
    end
    it "should return 200 for 'inbox'" do
      VCR.use_cassette "controllers/v1/private_messages/inbox_with_key" do
        request.env['oauth_token'] = @public_oauth_token
        request.env['Authorization'] = 'Token token="'+@api_key+'"'
        get 'inbox', 'membername' => 'jeffdonthemic'
        response.response_code.should == 200
      end
    end
    it "should return 200 for 'create'" do
      VCR.use_cassette "controllers/v1/private_messages/create_with_key" do
        request.env['oauth_token'] = @public_oauth_token
        request.env['Authorization'] = 'Token token="'+@api_key+'"'
        post 'create', 'membername' => 'jeffdonthemic'
        response.response_code.should == 200
      end
    end
    it "should return 200 for 'update'" do
      VCR.use_cassette "controllers/v1/private_messages/update_with_key" do
        request.env['oauth_token'] = @public_oauth_token
        request.env['Authorization'] = 'Token token="'+@api_key+'"'
        put 'update', 'id' => '1', 'data' => 'jeffdonthemic'
        response.response_code.should == 200
      end
    end
    it "should return 200 for 'reply'" do
      VCR.use_cassette "controllers/v1/private_messages/all_for_find" do
        results = PrivateMessage.to(@public_oauth_token, 'jeffdonthemic')
        @message_id = results.first.id
      end
      VCR.use_cassette "controllers/v1/private_messages/reply_with_key" do
        request.env['oauth_token'] = @public_oauth_token
        request.env['Authorization'] = 'Token token="'+@api_key+'"'
        post 'reply', 'id' => @message_id, 'data' => 'jeffdonthemic'
        response.response_code.should == 200
      end
    end
  end

end
