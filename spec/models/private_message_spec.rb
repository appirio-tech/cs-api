require 'spec_helper'

describe PrivateMessage do

  # get oauth tokens for different users
  before(:all) do
    VCR.use_cassette "shared/public_oauth_token", :record => :all do
      @public_oauth_token = SfdcHelper.public_access_token
    end
  end 

  describe "'to' messages" do
    it "should return a collection" do
      VCR.use_cassette "models/private_message/to" do
        results = PrivateMessage.to(@public_oauth_token, 'jeffdonthemic')
      end
    end
  end     

  describe "'inbox' messages" do
    it "should return a collection" do
      VCR.use_cassette "models/private_message/inbox" do
        results = PrivateMessage.inbox(@public_oauth_token, 'jeffdonthemic')
      end
    end
  end 

  describe "'from' messages" do
    it "should return a collection" do
      VCR.use_cassette "models/private_message/from" do
        results = PrivateMessage.from(@public_oauth_token, 'jeffdonthemic')
      end
    end
  end 

  describe "'create' message" do
    it "should create a message successfully" do
      VCR.use_cassette "models/private_message/create_success" do
        data = { 'from' => 'jeffdonthemic', 'to' => 'mess', 
          'subject' => 'some subject', 'body' => 'the<br/>body' }
        results = PrivateMessage.create(@public_oauth_token, data)
        results[:success].should == true
        results[:message].should == 'Notification successfully sent.'
      end
    end
    it "should return an error gracefully" do
      VCR.use_cassette "models/private_message/create_error" do
        data = { 'from' => 'badmember', 'to' => 'mess', 
          'subject' => 'some subject', 'body' => 'the<br/>body' }
        results = PrivateMessage.create(@public_oauth_token, data)
        results[:success].should == false
        results[:message].should == 'Member badmember not found.'
      end
    end    
  end 

  describe "'find' a message" do
    it "should return the message" do
      VCR.use_cassette "models/private_message/all_for_find" do
        results = PrivateMessage.to(@public_oauth_token, 'jeffdonthemic')
        @message_id = results.first.id
      end
      VCR.use_cassette "models/private_message/find" do
        results = PrivateMessage.find(@public_oauth_token, @message_id)
        results.id.should == @message_id
      end
    end
  end 

  describe "'reply' to a message" do
    it "should create reply successfully" do
      # get a message to reply to
      VCR.use_cassette "models/private_message/all_for_reply" do
        results = PrivateMessage.to(@public_oauth_token, 'jeffdonthemic')
        @message_id = results.first.id
      end
      VCR.use_cassette "models/private_message/reply" do
        data = { 'from' => 'jeffdonthemic', 'to' => 'mess', 
          'subject' => 'some subject', 'body' => 'the<br/>body' }
        results = PrivateMessage.reply(@public_oauth_token, @message_id, data)
        results[:success].should == true
        results[:message].should == 'Notification successfully sent.'
      end
    end
  end   

  describe "'update' to a message" do
    it "should update successfully" do
      # get a message to reply to
      VCR.use_cassette "models/private_message/all_for_update" do
        results = PrivateMessage.to(@public_oauth_token, 'jeffdonthemic')
        @message_id = results.first.id
      end
      VCR.use_cassette "models/private_message/update" do
        data = { 'status_from' => 'Read'}
        results = PrivateMessage.update(@public_oauth_token, @message_id, data)
        results[:success].should == true
      end
    end
  end  

end