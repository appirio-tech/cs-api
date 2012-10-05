require 'spec_helper'

describe Account do

  # get oauth tokens for different users
  before(:all) do
    puts "[SETUP] fetching new access tokens....."
    VCR.use_cassette "models/accounts/get_public_oauth_token", :record => :all do
      config = YAML.load_file(File.join(::Rails.root, 'config', 'databasedotcom.yml'))
      client = Databasedotcom::Client.new(config)
      @public_oauth_token = client.authenticate :username => ENV['SFDC_PUBLIC_USERNAME'], :password => ENV['SFDC_PUBLIC_PASSWORD']
    end

    VCR.use_cassette "models/accounts/get_admin_oauth_token", :record => :all do
      config = YAML.load_file(File.join(::Rails.root, 'config', 'databasedotcom.yml'))
      client = Databasedotcom::Client.new(config)
      @admin_oauth_token = client.authenticate :username => ENV['SFDC_ADMIN_USERNAME'], :password => ENV['SFDC_ADMIN_PASSWORD']
    end
  end  

  describe "'find' account" do
    it "should return jeffdonthemic with github" do
      VCR.use_cassette "models/accounts/find_account_jeffdonthemic" do
        results = Account.find_by_service(@admin_oauth_token, 
          'github', 'jeffdonthemic')
        results[:success].should == 'true'
        results[:username].should == 'jeffdonthemic'
        results[:sfdc_username].should == "jeffdonthemic@m.cloudspokes.com.sandbox"
        results.should have_key(:profile_pic)
        results.should have_key(:email)
        results.should have_key(:accountid)
      end
    end

    it "should not return a non-existent account" do
      VCR.use_cassette "models/accounts/find_account_unknown_user" do
        results = Account.find_by_service(@admin_oauth_token , 
          'github', 'unknown-user')
        results[:success].should == 'false'
        results[:message].should == 'No user could be found with specified service and username.'
      end
    end    

    it "should not return jeffdonthemic for wrong service" do
      VCR.use_cassette "models/accounts/find_jeffdothemic_cs_failure" do
        results = Account.find_by_service(@admin_oauth_token, 'cloudspokes', 'jeffdonthemic')
        results[:success].should == 'false'
        results[:message].should == 'CloudSpokes managed member not found for jeffdonthemic.'
      end
    end 

  end

  describe "authenticate" do
    it "should authenticate correctly" do
      VCR.use_cassette "models/accounts/authenticate_success" do
        puts "=== calling Account.authenticate..."
        results = Account.authenticate(@public_oauth_token, 
          'rspec', ENV['SFDC_PUBLIC_PASSWORD'])
        results[:success].should == 'true'
        results[:message].should == 'Successful sfdc login.'
        results.should have_key(:access_token)
      end
    end

    it "should display the correct message if no password match" do
      VCR.use_cassette "models/accounts/authenticate_failure_bad_password" do
        results = Account.authenticate(@public_oauth_token, 
          'rspec', 'bad-password')
        results[:success].should == 'false'
        results[:message].should == 'authentication failure - Invalid Password'
      end
    end   

    it "should display the correct message if invalid username" do
      VCR.use_cassette "models/accounts/authenticate_failure_bad_username" do
        results = Account.authenticate(@public_oauth_token, 
          'baduser1', 'bad-password')
        results[:success].should == 'false'
        results[:message].should == 'expired access/refresh token'
      end
    end 

  end 


  describe "create a new account" do
    it "should create a cloudspokes account successfully" do
      VCR.use_cassette "models/accounts/create_cs_account_success" do
        username = 'cloudspokes-rspec-1'
        params = { :username => username, :password => '!abcd123456',
          :email => "#{username}@test.com" }
        results = Account.create(@public_oauth_token, params)
        results[:success].should == 'true'
        results[:sfdc_username].should == "#{username}@m.cloudspokes.com.sandbox"
        results[:username].should == username
        results[:message].should == 'Member created successfully.'
      end
    end

    it "should create a third-party account successfully" do
      VCR.use_cassette "models/accounts/create_thirdparty_account_success" do
        username = 'thirdparty-rspec-1'
        params = { :username => username, :email => "#{username}@test.com", :provider => 'github',
          :name => 'Jeff Douglas', :provider_username => "#{username}@test.com" }  
        results = Account.create(@public_oauth_token, params)
        results[:success].should == 'true'
        results[:sfdc_username].should == "#{username}@m.cloudspokes.com.sandbox"
        results[:username].should == username
        results[:message].should == 'Member created successfully.'
      end
    end

    it "should create a third-party account successfully with a blank name" do
      VCR.use_cassette "models/accounts/create_thirdparty_blank_name_account_success" do
        username = 'thirdparty-rspec-2'
        params = { :username => username, :email => "#{username}@test.com", :provider => 'github',
          :name => '', :provider_username => "#{username}@test.com" }  
        results = Account.create(@public_oauth_token, params)
        results[:success].should == 'true'
        results[:sfdc_username].should == "#{username}@m.cloudspokes.com.sandbox"
        results[:username].should == username
        results[:message].should == 'Member created successfully.'
      end
    end 

    it "should not create with fields missing" do
      VCR.use_cassette "models/accounts/create_account_missing_fields_failure" do
        username = 'thirdparty-rspec-3'
        params = { :username => username, :password => '!abcd123456' }  
        results = Account.create(@public_oauth_token, params)
        results[:success].should == 'false'
        results[:message].should == "Required parameters are missing. You must pass values for the following: username__c, email__c, last_name__c, first_name__c."
      end
    end    

    it "should not create a duplicate user" do
      VCR.use_cassette "models/accounts/create_cs_account_duplicate" do
        username = 'thirdparty-rspec-2'
        params = { :username => username, :email => "#{username}@test.com", :provider => 'github',
          :name => '', :provider_username => "#{username}@test.com" }  
        results = Account.create(@public_oauth_token, params)
        results[:success].should == 'false'
        results[:message].should == "Username #{username} is not available."
      end
    end    

  end   

  describe "password reset" do
    it "should send the passcode correctly" do
      VCR.use_cassette "models/accounts/reset_password_success" do
        membername = 'mandrill4'
        results = Account.reset_password(@public_oauth_token, membername)
        results[:success].should == 'true'
        results[:message].should == "An email containing a passcode code is being sent to the registered email address of #{membername}."
      end
    end

    it "should return failure for non-existent member" do
      VCR.use_cassette "models/accounts/reset_password_bad_member" do
        membername = 'bad-member'
        results = Account.reset_password(@public_oauth_token, membername)
        results[:success].should == 'false'
        results[:message].should == "The username that you specified was not found: #{membername}"
      end
    end    

  end

  describe "upate password" do

    it "should return failure for non-matching passcode" do
      VCR.use_cassette "models/accounts/reset_update_bad_passcode" do
        membername = 'mandrill4'
        results = Account.update_password(@public_oauth_token, membername, '0', 'ABCDE12345')
        results[:success].should == 'false'
        results[:message].should == "Could not find a matching passcode for the provided username: #{membername}"
      end
    end  

    it "should return failure for invalid password" do
      VCR.use_cassette "models/accounts/reset_update_invalid_password" do
        membername = 'mandrill4'
        results = Account.update_password(@public_oauth_token, membername, '86675', 'A')
        results[:success].should == 'false'
        results[:message].should == "INVALID_NEW_PASSWORD: Your password must be at least 5 characters long."
      end
    end      

    it "should update the password successfully" do
      VCR.use_cassette "models/accounts/reset_update_success" do
        membername = 'mandrill4'
        results = Account.update_password(@public_oauth_token, membername, '86675', 'ABCDE12345!')
        results[:success].should == 'true'
        results[:message].should == "Password changed successfully."
      end
    end  

  end    

end
