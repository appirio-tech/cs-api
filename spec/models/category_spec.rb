require 'spec_helper'

describe Category do

  # get oauth tokens for different users
  before(:all) do
    puts "[SETUP] fetching new access tokens....."
    VCR.use_cassette "shared/public_oauth_token", :record => :all do
      config = YAML.load_file(File.join(::Rails.root, 'config', 'databasedotcom.yml'))
      client = Databasedotcom::Client.new(config)
      @public_oauth_token = client.authenticate :username => ENV['SFDC_PUBLIC_USERNAME'], :password => ENV['SFDC_PUBLIC_PASSWORD']
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