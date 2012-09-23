require 'spec_helper'

describe V1::AccountsController do

  # create a new api_key so all methods can use it
  before(:all) do
    VCR.use_cassette "controllers/v1/accounts/get_public_oauth_token", :record => :all do
      config = YAML.load_file(File.join(::Rails.root, 'config', 'databasedotcom.yml'))
      client = Databasedotcom::Client.new(config)
      @public_oauth_token = client.authenticate :username => ENV['SFDC_PUBLIC_USERNAME'], :password => ENV['SFDC_PUBLIC_PASSWORD']
    end

    ApiKey.create!
    @api_key = ApiKey.first.access_key
  end  

  describe "methods without api key" do
    it "should return 401 for 'find'" do
      request.env['oauth_token'] = @public_oauth_token
      get 'find', 'membername' => 'jeffdonthemic', 'service' => 'github'
      response.should_not be_success
    end

    it "should return 401 for 'create'" do
      request.env['oauth_token'] = @public_oauth_token
      post 'create', 'username' => 'anyname', 'password' => '!abcd123456',
        'email' => 'anyname@test.com'
      response.should_not be_success
    end    

    it "should return 401 for 'authenticate'" do
      request.env['oauth_token'] = @public_oauth_token
      post 'authenticate', 'membername' => 'jeffdonthemic', 'password' => ''
      response.should_not be_success
    end        
  end

  describe "methods with api key" do
    it "should return 200 for 'find'" do
      VCR.use_cassette "controllers/v1/accounts/find_account_jeffdonthemic" do
        request.env['oauth_token'] = @public_oauth_token
        request.env['Authorization'] = 'Token token="'+@api_key+'"'
        get 'find', 'membername' => 'jeffdonthemic', 'service' => 'github'
        response.should be_success
      end
    end       
  end

  describe "'find' jeffdonthemic with github" do
    it "should have the correct keys" do
      VCR.use_cassette "controllers/v1/accounts/find_account_jeffdonthemic" do
        request.env['oauth_token'] = @public_oauth_token
        request.env['Authorization'] = 'Token token="'+@api_key+'"'
        get 'find', 'membername' => 'jeffdonthemic', 'service' => 'github'
        h = JSON.parse(response.body)['response']
        keys = %w{success username sfdc_username profile_pic email accountid}
        keys.each do |k|
          h.should have_key(k)
        end
      end
    end 
  end

end
