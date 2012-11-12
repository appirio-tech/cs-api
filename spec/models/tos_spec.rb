require 'spec_helper'

describe Tos do

  # get oauth tokens for different users
  before(:all) do
    puts "[SETUP] fetching new access tokens....."
    VCR.use_cassette "models/tos/get_public_oauth_token", :record => :all do
      config = YAML.load_file(File.join(::Rails.root, 'config', 'databasedotcom.yml'))
      client = Databasedotcom::Client.new(config)
      @public_oauth_token = client.authenticate :username => ENV['SFDC_PUBLIC_USERNAME'], :password => ENV['SFDC_PUBLIC_PASSWORD']
    end
  end 	

  describe "find tos" do
	  it "should return a tos correctly" do
	    VCR.use_cassette "models/tos/find" do
	      results = Tos.find(@public_oauth_token, 'a0kJ0000000AoTDIA0')
	      results.should have_key('terms')
	      results.should have_key('default_tos')
	      results.should have_key('name')
	    end
	  end
  end  	

end