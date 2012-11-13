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

    @rspec_user1_name = 'rspec-test-member-1'
    @rspec_user1_password = 'abcd123456'
    @rspec_user2_name = 'rspec-test-member-2'
    @rspec_user3_name = 'rspec-test-member-3'
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

  describe "create a new account" do
    it "should create a cloudspokes account successfully" do
      VCR.use_cassette "models/accounts/create_cs_account_success" do
        params = { :username => @rspec_user1_name, :password => @rspec_user1_password,
          :email => "#{@rspec_user1_name}@test.com" }
        results = Account.create(@public_oauth_token, params)
        results[:success].should == 'true'
        results[:sfdc_username].should == "#{@rspec_user1_name}@m.cloudspokes.com.sandbox"
        results[:username].should == @rspec_user1_name
        results[:message].should == 'Member created successfully.'
      end
    end

    it "should create a third-party account successfully" do
      VCR.use_cassette "models/accounts/create_thirdparty_account_success" do
        params = { :username => @rspec_user2_name, :email => "#{@rspec_user2_name}@test.com", 
          :provider => 'github', :name => 'Rspec TestUser', 
          :provider_username => "#{@rspec_user2_name}@test.com" }  
        results = Account.create(@public_oauth_token, params)
        results[:success].should == 'true'
        results[:sfdc_username].should == "#{@rspec_user2_name}@m.cloudspokes.com.sandbox"
        results[:username].should == @rspec_user2_name
        results[:message].should == 'Member created successfully.'
      end
    end

    it "should create a third-party account successfully with a blank name" do
      VCR.use_cassette "models/accounts/create_thirdparty_blank_name_account_success" do
        params = { :username => @rspec_user3_name, :email => "#{@rspec_user3_name}@test.com", 
          :provider => 'github', :name => '', :provider_username => "#{@rspec_user3_name}@test.com" }  
        results = Account.create(@public_oauth_token, params)
        results[:success].should == 'true'
        results[:sfdc_username].should == "#{@rspec_user3_name}@m.cloudspokes.com.sandbox"
        results[:username].should == @rspec_user3_name
        results[:message].should == 'Member created successfully.'
      end
    end 

    it "should not create with fields missing" do
      VCR.use_cassette "models/accounts/create_account_missing_fields_failure" do
        params = { :username => 'somebadname', :password => '!abcd123456' }  
        results = Account.create(@public_oauth_token, params)
        results[:success].should == 'false'
        results[:message].should == "Required parameters are missing. You must pass values for the following: username__c, email__c, last_name__c, first_name__c."
      end
    end    

    it "should not create a duplicate user" do
      VCR.use_cassette "models/accounts/create_cs_account_duplicate" do
        params = { :username => @rspec_user1_name, :email => "#{@rspec_user1_name}@test.com", 
          :provider => 'github', :name => '', :provider_username => "#{@rspec_user1_name}@test.com" }  
        results = Account.create(@public_oauth_token, params)
        results[:success].should == 'false'
        results[:message].should == "Username #{@rspec_user1_name} is not available."
      end
    end    

  end   

  describe "authenticate" do
    it "should authenticate correctly" do
      VCR.use_cassette "models/accounts/authenticate_success" do
        results = Account.authenticate(@public_oauth_token, 
          @rspec_user1_name, @rspec_user1_password)
        results[:success].should == 'true'
        results[:message].should == 'Successful sfdc login.'
        results.should have_key(:access_token)
      end
    end

    it "should display the correct message if no password match" do
      VCR.use_cassette "models/accounts/authenticate_failure_bad_password" do
        results = Account.authenticate(@public_oauth_token, 
          @rspec_user1_name, 'bad-password')
        results[:success].should == 'false'
        results[:message].should == 'authentication failure - Invalid Password'
      end
    end   

    it "should display the correct message if invalid username" do
      VCR.use_cassette "models/accounts/authenticate_failure_bad_username" do
        results = Account.authenticate(@public_oauth_token, 
          'non-existent-user', 'bad-password')
        results[:success].should == 'false'
        results[:message].should == 'expired access/refresh token'
      end
    end 

  end   

  describe "password reset" do
    it "should send the passcode correctly" do
      VCR.use_cassette "models/accounts/reset_password_success" do
        results = Account.reset_password(@public_oauth_token, @rspec_user1_name)
        results[:success].should == 'true'
        results[:message].should == "An email containing a passcode code is being sent to the registered email address of #{@rspec_user1_name}."
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
        results = Account.update_password(@public_oauth_token, @rspec_user1_name, '0', 'ABCDE12345')
        results[:success].should == 'false'
        results[:message].should == "Could not find a matching passcode for the provided username: #{@rspec_user1_name}"
      end
    end  

    it "should return failure for invalid password" do
      VCR.use_cassette "models/accounts/reset_update_invalid_password" do
        results = Account.update_password(@public_oauth_token, @rspec_user1_name, '83647', 'A')
        results[:success].should == 'false'
        results[:message].should == "INVALID_NEW_PASSWORD: Your password must be at least 5 characters long."
      end
    end      

    it "should update the password successfully" do
      VCR.use_cassette "models/accounts/reset_update_success" do
        results = Account.update_password(@public_oauth_token, @rspec_user1_name, '83647', @rspec_user1_password)
        results[:success].should == 'true'
        results[:message].should == "Password changed successfully."
      end
    end  

  end   

  describe "activate" do
    it "should successfully activate an account" do
      VCR.use_cassette "models/accounts/activate" do
        results = Account.activate(@public_oauth_token, 
          @rspec_user1_name)
        puts results.should == true
      end
    end

  end      

end
