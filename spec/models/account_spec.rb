require 'spec_helper'

=begin
  After wiping out all of the cassettes and running all of the specs again, 
  [it "should authenticate correctly"] will fail as sfdc will always return
  an oath error until the user has been provisioned and replicated in 
  their infrastructure. Just wait a few minutes and run this spec again. PITA.
=end

describe Account do

  # get oauth tokens for different users
  before(:all) do
    VCR.use_cassette "shared/public_oauth_token", :record => :all do
      @public_oauth_token = SfdcHelper.public_access_token
    end

    VCR.use_cassette "shared/admin_oauth_token", :record => :all do
      @admin_oauth_token = SfdcHelper.admin_access_token
    end

    @restforce_client = Restforce.new :oauth_token => @admin_oauth_token,
      :instance_url  => ENV['SFDC_INSTANCE_URL']    

    @rspec_test_password = 'abcd123456'

    # create the rspec testing user
    VCR.use_cassette "models/accounts/create_rspec_testing_user" do
      @rspec_test_membername = (0...6).map{65.+(rand(26)).chr}.join+rand(100).to_s
      params = { :username => @rspec_test_membername, :password => @rspec_test_password,
        :email => "#{@rspec_test_membername}@rspec.cloudspokes.com" }
      results = Account.create(@public_oauth_token, params)
      @rspec_test_membername = results[:username]
      puts "[SETUP]Created rspec testing member (#{@rspec_test_membername}) successfully? #{results[:success]}"
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

  describe "create a new account" do
    it "should create a cloudspokes account successfully" do
      VCR.use_cassette "models/accounts/create_cs_account_success", :re_record_interval => 1 do
        membername = (0...10).map{65.+(rand(26)).chr}.join+rand(100).to_s
        params = { :username => membername, :password => @rspec_test_password,
          :email => "#{membername}@rspec.cloudspokes.com" }
        results = Account.create(@public_oauth_token, params)
        results[:success].should == 'true'
        results[:sfdc_username].should == "#{membername}@m.cloudspokes.com.sandbox"
        results[:username].should == membername
        results[:message].should == 'Member created successfully.'
      end
    end

    it "should create a third-party account successfully" do
      VCR.use_cassette "models/accounts/create_thirdparty_account_success", :re_record_interval => 1 do
        membername = (0...10).map{65.+(rand(26)).chr}.join+rand(100).to_s
        params = { :username => membername, :email => "#{membername}@rspec.cloudspokes.com", 
          :provider => 'github', :name => 'Rspec TestUser', 
          :provider_username => "#{membername}@rspec.cloudspokes.com" }  
        results = Account.create(@public_oauth_token, params)
        results[:success].should == 'true'
        results[:sfdc_username].should == "#{membername}@m.cloudspokes.com.sandbox"
        results[:username].should == membername
        results[:message].should == 'Member created successfully.'
      end
    end

    it "should create a third-party account successfully with a blank name" do
      VCR.use_cassette "models/accounts/create_thirdparty_blank_name_account_success", :re_record_interval => 1 do
        membername = (0...10).map{65.+(rand(26)).chr}.join+rand(100).to_s
        params = { :username => membername, :email => "#{membername}@rspec.cloudspokes.com", 
          :provider => 'github', :name => '', :provider_username => "#{membername}@rspec.cloudspokes.com" }  
        results = Account.create(@public_oauth_token, params)
        results[:success].should == 'true'
        results[:sfdc_username].should == "#{membername}@m.cloudspokes.com.sandbox"
        results[:username].should == membername
        results[:message].should == 'Member created successfully.'
      end
    end 

    it "should not create with fields missing" do
      VCR.use_cassette "models/accounts/create_account_missing_fields_failure", :re_record_interval => 1 do
        params = { :username => 'somebadname', :password => '!abcd123456' }  
        results = Account.create(@public_oauth_token, params)
        results[:success].should == 'false'
        results[:message].should == "Required parameters are missing. You must pass values for the following: username__c, email__c, last_name__c, first_name__c."
      end
    end    

    it "should not create a duplicate user" do
      VCR.use_cassette "models/accounts/create_cs_account_duplicate", :re_record_interval => 1 do
        params = { :username => @rspec_test_membername, :email => "#{@rspec_test_membername}@rspec.cloudspokes.com", 
          :provider => 'github', :name => '', :provider_username => "#{@rspec_test_membername}@rspec.cloudspokes.com" }  
        results = Account.create(@public_oauth_token, params)
        results[:success].should == 'false'
        results[:message].should == "Username #{@rspec_test_membername} is not available."
      end
    end    

  end   

  describe "authenticate" do
    # there may be an issue with sfdc 
    it "should authenticate correctly" do
      VCR.use_cassette "models/accounts/authenticate_success" do
        results = Account.authenticate(@public_oauth_token, 
          @rspec_test_membername, @rspec_test_password)
        results[:success].should == 'true'
        results[:message].should == 'Successful sfdc login.'
        results.should have_key(:access_token)
      end
    end

    it "should return false if no password match" do
      VCR.use_cassette "models/accounts/authenticate_failure_bad_password" do
        results = Account.authenticate(@public_oauth_token, 
          @rspec_test_membername, 'bad-password')
        results[:success].should == 'false'
      end
    end   

    it "should return false if invalid username" do
      VCR.use_cassette "models/accounts/authenticate_failure_bad_username" do
        results = Account.authenticate(@public_oauth_token, 
          'non-existent-user', 'bad-password')
        results[:success].should == 'false'
      end
    end 

  end   

  describe "password reset" do
    it "should send the passcode correctly" do
      VCR.use_cassette "models/accounts/reset_password_success" do
        results = Account.reset_password(@public_oauth_token, @rspec_test_membername)
        results[:success].should == 'true'
        results[:message].should == "An email containing a passcode code is being sent to the registered email address of #{@rspec_test_membername}."
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
        results = Account.update_password(@public_oauth_token, @rspec_test_membername, '0', 'ABCDE12345')
        results[:success].should == 'false'
        results[:message].should == "Could not find a matching passcode for the provided username: #{@rspec_test_membername}"
      end
    end  

    it "should return failure for invalid password" do
      # reset the password
      VCR.use_cassette "models/accounts/reset_password_for_invalid", :record => :all do
        results = Account.reset_password(@public_oauth_token, @rspec_test_membername)
        puts "Resetting password ..... #{results}"
      end         
      # get the actual passcode for the user
      VCR.use_cassette "models/accounts/get_user_passcode", :record => :all do
        @passcode = @restforce_client.query("select passcode__c from user where 
          username = '#{@rspec_test_membername}@m.cloudspokes.com.sandbox'").first['Passcode__c']  
        puts "Getting the user's passcode ..... #{@passcode}"
      end
      VCR.use_cassette "models/accounts/reset_update_invalid_password", :record => :all do
        puts "Updating password ...."
        results = Account.update_password(@public_oauth_token, @rspec_test_membername, @passcode, 'A')
        results[:success].should == 'false'
        results[:message].should == "INVALID_NEW_PASSWORD: Your password must be at least 5 characters long."
      end
    end      

    it "should update the password successfully" do
      # reset the password
      VCR.use_cassette "models/accounts/reset_password_for_success", :record => :all do
        results = Account.reset_password(@public_oauth_token, @rspec_test_membername)
        puts "Resetting password ..... #{results}"
      end          
      # get the actual passcode for the user
      VCR.use_cassette "models/accounts/get_user_passcode", :record => :all do
        @passcode = @restforce_client.query("select passcode__c from user where 
          username = '#{@rspec_test_membername}@m.cloudspokes.com.sandbox'").first['Passcode__c'] 
        puts "Getting the user's passcode ..... #{@passcode}" 
      end    
      VCR.use_cassette "models/accounts/reset_update_success", :record => :all do
        puts "Updating password ...."
        results = Account.update_password(@public_oauth_token, @rspec_test_membername, @passcode, @rspec_test_password)
        results[:success].should == 'true'
        results[:message].should == "Password changed successfully."
      end
    end  

  end   

  describe "activate" do
    it "should successfully activate an account" do
      VCR.use_cassette "models/accounts/activate" do
        results = Account.activate(@public_oauth_token, 
          @rspec_test_membername)
        puts results.should == true
      end
    end

  end      

end
