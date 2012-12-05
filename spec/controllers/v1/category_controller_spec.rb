require 'spec_helper'

describe V1::CategoriesController do

  # create a new api_key so all methods can use it
  before(:all) do
    VCR.use_cassette "shared/public_oauth_token", :record => :all do
      config = YAML.load_file(File.join(::Rails.root, 'config', 'databasedotcom.yml'))
      client = Databasedotcom::Client.new(config)
      @public_oauth_token = client.authenticate :username => ENV['SFDC_PUBLIC_USERNAME'], :password => ENV['SFDC_PUBLIC_PASSWORD']
    end
  end  

  describe "all categories" do
    it "should return correctly" do
      VCR.use_cassette "controllers/v1/category/all" do
        request.env['oauth_token'] = @public_oauth_token
        get 'all'
        response.should be_success
      end
    end       
  end

end