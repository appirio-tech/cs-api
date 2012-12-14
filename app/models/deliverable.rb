class Deliverable < Salesforce

  #
  # Returns all deliverables for a participant
  # * *Args*    :
  #   - access_token -> the oauth token to use
  #   - membername -> the participant's cloudspokes member name
  #   - challenge_id -> the participant's challenge id
  # * *Returns* :
  #   - JSON collection of deliverables objects
  # * *Raises* :
  #   - ++ ->
  #  
  def self.all(access_token, membername, challenge_id) 
    query_salesforce(access_token, "select Id, Type__c, Comments__c, Username__c, Password__c, Language__c, 
      URL__c, Hosting_Platform__c from Submission_Deliverable__c 
      where Challenge_Participant__r.Member__r.Name = '#{membername}' and 
      Challenge_Participant__r.Challenge__r.Challenge_Id__c = '#{challenge_id}'")
  end 

  def self.create(access_token, membername, challenge_id, data)
    # get the challenge participant's id
    data['challenge_participant'] = query_salesforce(access_token, 
      "select id from challenge_participant__c where member__r.name = '#{membername}' 
      and challenge__r.challenge_id__c = '#{challenge_id}'").first['id']

    create_in_salesforce(access_token, 'Submission_Deliverable__c', 
      Forcifier::JsonMassager.enforce_json(data))
  end     

  def self.update(access_token, data)
    update_in_salesforce(access_token, 'Submission_Deliverable__c', 
      Forcifier::JsonMassager.enforce_json(data))
  end        

end