class Participant < Salesforce

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
    get_apex_rest("/participants/#{esc membername}?challengeId=#{challenge_id}").first
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