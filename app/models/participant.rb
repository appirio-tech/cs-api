class Participant < Salesforce

  def self.find(access_token, participant_id)  
    query_salesforce(access_token, "select Id, Member__c, Member__r.name, 
      Member__r.Profile_Pic__c, Member__r.Country__c, Challenge__c, Challenge__r.Name, 
      Challenge__r.Challenge_Id__c, Money_Awarded__c, Place__c, Points_Awarded__c, 
      Score__c, Status__c, Has_Submission__c, Completed_Scorecards__c, 
      Submitted_Date__c, Send_Discussion_Emails__c 
      from Challenge_Participant__c where id = '#{participant_id}'").first
  end   

  #
  # Returns the status for a member for a challenge
  # * *Args*    :
  #   - access_token -> the oauth token to use
  #   - membername -> the participant's cloudspokes member name
  #   - challenge_id -> the participant's challenge id
  # * *Returns* :
  #   - JSON containing the following keys: success, message
  # * *Raises* :
  #   - ++ ->
  #  
  def self.status(access_token, membername, challenge_id) 
    set_header_token(access_token)  
    get_apex_rest("/participants/#{esc membername}?challengeId=#{challenge_id}&fields=id,name,send_discussion_emails__c,status__c,place__c,money_awarded__c,has_submission__c,challenge__r.name,challenge__r.challenge_id__c,member__r.name,member__r.valid_submissions__c").first
  end		

  #
  # Creates a new challenge_participant records
  # if the member/challenge combination doesn't
  # exixt (this is handled in the Apex REST)
  # * *Args*    :
  #   - access_token -> the oauth token to use
  #   - membername -> the participant's cloudspokes member name
  #   - challenge_id -> the participant's challenge id
  #   - fields -> the field to populate for the creation (enforces them)
  # * *Returns* :
  #   - JSON containing the following keys: success, message
  # * *Raises* :
  #   - ++ ->
  #  
  def self.create(access_token, membername, challenge_id, fields) 
    set_header_token(access_token) 
    # enforce the fields names
    fields = Forcifier::JsonMassager.enforce_json(fields)
    # add the username and challenge id for the apex rest
    fields['username'] = membername
    fields['challengeid'] = challenge_id
    #add all of the fields to the body of the post request
		options = {
		  :body => fields
		}	    		
		results = post(ENV['SFDC_APEXREST_URL']+'/participants', options)	
		{:success => results['Success'], :message => results['Message']}
  end	

  #
  # Updaes an existing challenge_participant record
  # * *Args*    :
  #   - access_token -> the oauth token to use
  #   - membername -> the participant's cloudspokes member name
  #   - challenge_id -> the participant's challenge id
  #   - fields -> the field to populate for the update (enforces them)
  # * *Returns* :
  #   - JSON containing the following keys: success, message
  # * *Raises* :
  #   - ++ ->
  #  
  def self.update(access_token, membername, challenge_id, fields) 
    set_header_token(access_token) 
    # enforce the fields names
    fields = Forcifier::JsonMassager.enforce_json(fields)
    # create nvp to pass as part of the url    
    field_nvp = fields.map{|k,v| "#{k}=#{v}"}.join('&')  
    results = put(ENV['SFDC_APEXREST_URL'] +
    	"/participants/#{esc membername}?challengeid=#{challenge_id}&#{field_nvp}")
    {:success => results['Success'], :message => results['Message']}
  end

end