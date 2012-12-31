class PrivateMessage < Salesforce

  def self.all(access_token) 
    query_salesforce(access_token, "select Id, Name, CreatedDate, LastModifiedDate, 
      To__c, To__r.Name, To__r.Profile_Pic__c, From__c, From__r.Name, From__r.Profile_Pic__c, Subject__c, 
      Status_From__c, Status_To__c, Replies__c
      from Private_Message__c 
      order by lastmodifieddate desc")
  end  

  def self.inbox(access_token, membername) 
    query_salesforce(access_token, "select Id, Name, CreatedDate, LastModifiedDate, 
      To__c, To__r.Name, To__r.Profile_Pic__c, From__c, From__r.Name, From__r.Profile_Pic__c, Subject__c, 
      Status_From__c, Status_To__c, Replies__c
      from Private_Message__c where To__r.Name = '#{membername}' OR (From__r.Name = '#{membername}' AND Replies__c > 0)
      order by lastmodifieddate desc")
  end  

  def self.to(access_token, membername) 
    query_salesforce(access_token, "select Id, Name, CreatedDate, LastModifiedDate, 
      To__c, To__r.Name, To__r.Profile_Pic__c, From__c, From__r.Name, From__r.Profile_Pic__c, Subject__c, 
      Status_From__c, Status_To__c, Replies__c
      from Private_Message__c where To__r.Name = '#{membername}'
      order by lastmodifieddate desc")
  end    

  def self.from(access_token, membername) 
    query_salesforce(access_token, "select Id, Name, CreatedDate, LastModifiedDate, 
      To__c, To__r.Name, To__r.Profile_Pic__c, From__c, From__r.Name, From__r.Profile_Pic__c, Subject__c, 
      Status_From__c, Status_To__c, Replies__c
      from Private_Message__c where From__r.Name = '#{membername}'
      order by lastmodifieddate desc")
  end      

  def self.find(access_token, id) 
    query_salesforce(access_token, "select Id, Name, CreatedDate, LastModifiedDate, To__c, To__r.Name,
      From__c, From__r.Name, Subject__c, Status_From__c, Status_To__c,  Replies__c,
      (select id, from__r.name, from__r.profile_pic__c, body__c, createddate from 
      Private_Message_Texts__r order by createddate) from Private_Message__c where Id = '#{id}'").first
  end    

  def self.create(access_token, data)
    set_header_token(access_token)
    options = {
      :body => {
          :fromId => Member.salesforce_member_id(access_token, data['from']),
          :toId => Member.salesforce_member_id(access_token, data['to']),
          :event  => 'Private Message',
          :subject => data['subject'],
          :body => data['body'] 
      }.to_json
    }

    results = post(ENV['SFDC_APEXREST_URL']+'/notifications', options)
    if results.first.has_key?('errorCode') 
      raise 'Sorry! Could not send private message!'
    else
      {:success => true, :message => 'Private message successfully sent.'}  
    end
  rescue Exception => e
    puts "[FATAL][PrivateMessage] Create new message exception: #{e.message} - #{results}" 
    {:success => false, :message => e.message}  
  end

  def self.update(access_token, id, data)
    # add the id of the record into the payload
    data['Id'] = id
    #update the private message
    update_results = update_in_salesforce(access_token, 'Private_Message__c', 
      Forcifier::JsonMassager.enforce_json(data)) 
    {:success => update_results[:success], :message => update_results[:message]}  
  rescue Exception => e
    puts "[FATAL][PrivateMessage] Update to message exception: #{e.message}" 
    {:success => false, :message => e.message}     
  end   

  def self.reply(access_token, id, data)
    set_header_token(access_token)
    # fetch the original message
    message = find(access_token, id)
    # set who the message is from
    fromId = Member.salesforce_member_id(access_token, data['from'])
    # figure out who is the corect to
    toId = fromId.eql?(message['from']) ? message['to'] : message['from']

    options = {
      :body => {
          :fromId => fromId,
          :toId => toId,
          :event  => 'Private Message',
          :subject => message['subject'],
          :body => data['body'],
          :parentId => id
      }.to_json
    }

    results = post(ENV['SFDC_APEXREST_URL']+'/notifications', options)
    if results.first.has_key?('errorCode') 
      raise 'Sorry! Could not send private message!'
    else
      {:success => true, :message => 'Private message reply successfully sent.'}  
    end
  rescue Exception => e
    puts "[FATAL][PrivateMessage] Private message reply exception: #{e.message} - #{results}" 
    {:success => false, :message => e.message}  
  end      

end