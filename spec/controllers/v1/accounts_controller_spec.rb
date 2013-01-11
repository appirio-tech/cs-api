require 'spec_helper'

describe V1::AccountsController do

  # create a new api_key so all methods can use it
  before(:all) do
    VCR.use_cassette "shared/public_oauth_token", :record => :all do
      @public_oauth_token = SfdcHelper.public_access_token
    end

    ApiKey.create!
    @api_key = ApiKey.first.access_key

    @rspec_user_name = 'test-rspec-create1'
    @rspec_user_password = '1111AAAAA!'
  end  

  describe "methods without api key" do
    it "should return 401 for 'find'" do
      request.env['oauth_token'] = @public_oauth_token
      get 'find_by_service', 'service' => 'github', 'service_username' => 'jeffdonthemic'
      response.response_code.should == 401
    end

    it "should return 401 for 'create'" do
      request.env['oauth_token'] = @public_oauth_token
      post 'create', 'username' => 'anyname', 'password' => '!abcd123456',
        'email' => 'anyname@test.com'
      response.response_code.should == 401
    end    

    it "should return 401 for 'authenticate'" do
      request.env['oauth_token'] = @public_oauth_token
      post 'authenticate', 'membername' => 'jeffdonthemic', 'password' => ''
      response.response_code.should == 401
    end        
  end

  describe "methods with api key" do
    it "should return 200 for 'find'" do
      VCR.use_cassette "controllers/v1/accounts/find_account_jeffdonthemic" do
        request.env['oauth_token'] = @public_oauth_token
        request.env['Authorization'] = 'Token token="'+@api_key+'"'
        get 'find_by_service', 'service' => 'github', 'service_username' => 'jeffdonthemic'
        response.response_code.should == 200
      end
    end       
  end

  describe "'find' jeffdonthemic with github" do
    it "should have the correct keys" do
      VCR.use_cassette "controllers/v1/accounts/find_account_jeffdonthemic" do
        request.env['oauth_token'] = @public_oauth_token
        request.env['Authorization'] = 'Token token="'+@api_key+'"'
        get 'find_by_service', 'service' => 'github', 'service_username' => 'jeffdonthemic' 
        h = JSON.parse(response.body)['response']
        keys = %w{success username sfdc_username profile_pic email accountid}
        keys.each do |k|
          h.should have_key(k)
        end
      end
    end 
  end

  describe "'create' new account" do
    it "should be successful" do
      VCR.use_cassette "controllers/v1/accounts/create_account" do
        request.env['oauth_token'] = @public_oauth_token
        request.env['Authorization'] = 'Token token="'+@api_key+'"'
        post 'create', params = { :username => @rspec_user_name, 
          :password => @rspec_user_password,
          :email => "#{@rspec_user_name}@test.com" } 
        response.should be_success
      end
    end 
  end  

  describe "'activate' account" do
    it "should be successful" do
      VCR.use_cassette "controllers/v1/accounts/activate" do
        request.env['oauth_token'] = @public_oauth_token
        request.env['Authorization'] = 'Token token="'+@api_key+'"'
        get 'activate', 'membername' => @rspec_user_name
        response.should be_success
      end
    end 
  end    

  describe "'authenticate' account" do
    it "should be successful" do
      VCR.use_cassette "controllers/v1/accounts/authenticate" do
        request.env['oauth_token'] = @public_oauth_token
        request.env['Authorization'] = 'Token token="'+@api_key+'"'
        get 'authenticate', 'membername' => @rspec_user_name, 
          'password' => @rspec_user_password
        response.should be_success
      end
    end 
  end      

  describe "password reset" do
    it "should have the correct keys" do
      VCR.use_cassette "controllers/v1/accounts/password_reset" do
        request.env['oauth_token'] = @public_oauth_token
        request.env['Authorization'] = 'Token token="'+@api_key+'"'
        get 'reset_password', 'membername' => 'mandrill4'
        h = JSON.parse(response.body)['response']
        keys = %w{success message}
        keys.each do |k|
          h.should have_key(k)
        end
        response.should be_success
      end
    end       
  end  

  describe "password update" do
    it "should have the correct keys" do
      VCR.use_cassette "controllers/v1/accounts/password_update" do
        request.env['oauth_token'] = @public_oauth_token
        request.env['Authorization'] = 'Token token="'+@api_key+'"'
        put 'update_password', 'membername' => 'mandrill4', 'passcode' => '20367', 
          'new_password' => 'ABCDE12345!'
        h = JSON.parse(response.body)['response']
        keys = %w{success message}
        keys.each do |k|
          h.should have_key(k)
        end
        response.should be_success
      end
    end       
  end    

end
