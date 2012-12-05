require 'spec_helper'

describe V1::ParticipantsController do

  # create a new api_key so all methods can use it
  before(:all) do
    VCR.use_cassette "shared/public_oauth_token", :record => :all do
      config = YAML.load_file(File.join(::Rails.root, 'config', 'databasedotcom.yml'))
      client = Databasedotcom::Client.new(config)
      @public_oauth_token = client.authenticate :username => ENV['SFDC_PUBLIC_USERNAME'], :password => ENV['SFDC_PUBLIC_PASSWORD']
    end

    ApiKey.create!
    @api_key = ApiKey.first.access_key 

    # find a challenge is the sandbox that exists
    @challenge_id = '2'       
  end  

  describe "methods without api key" do
    it "should return 401 for 'current_status'" do
      request.env['oauth_token'] = @public_oauth_token
      get 'current_status', 'membername' => 'jeffdonthemcic',
      	'challenge_id' => @challenge_id
      response.response_code.should == 401
    end

    it "should return 401 for 'create'" do
      request.env['oauth_token'] = @public_oauth_token
      post 'create', 'membername' => 'jeffdonthemcic',
      	'challenge_id' => @challenge_id
      response.response_code.should == 401
    end     

    it "should return 401 for 'update'" do
      request.env['oauth_token'] = @public_oauth_token
      put 'update', 'membername' => 'jeffdonthemcic',
      	'challenge_id' => @challenge_id
      response.response_code.should == 401
    end           
  end

  describe "participants" do
        it "'create' should return successfully" do
      VCR.use_cassette "controllers/v1/participants/create" do
        request.env['oauth_token'] = @public_oauth_token
        request.env['Authorization'] = 'Token token="'+@api_key+'"'
        post 'create', 'membername' => 'jeffdonthemic',
          'challenge_id' => @challenge_id, 
          'fields' => {:status => 'Watching'}
        response.should be_success
      end
    end  

    it "'status' should return successfully" do
      VCR.use_cassette "controllers/v1/participants/status" do
        request.env['oauth_token'] = @public_oauth_token
        request.env['Authorization'] = 'Token token="'+@api_key+'"'
        get 'current_status', 'membername' => 'jeffdonthemic',
          'challenge_id' => @challenge_id
        response.should be_success
      end
    end  

    it "'update' should return successfully" do
      VCR.use_cassette "controllers/v1/participants/update" do
        request.env['oauth_token'] = @public_oauth_token
        request.env['Authorization'] = 'Token token="'+@api_key+'"'
        put 'update', 'membername' => 'jeffdonthemic',
          'challenge_id' => @challenge_id, 
          'fields' => {:status => 'Watching'}
        response.should be_success
      end
    end      

  end
end