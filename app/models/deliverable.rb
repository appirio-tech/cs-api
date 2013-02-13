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

  # this will go away with the new submissions process
  def self.current_submssions(access_token, membername, challenge_id) 
    set_header_token(access_token)
    get_apex_rest("/submissions?participantid=#{challenge_participant_id(membername, challenge_id)}")
  end

  # this will go away with the new submissions process
  def self.create_url_or_file_submission(access_token, membername, challenge_id, params)
    set_header_token(access_token)
    options = {
      :body => {
          :challenge_participant__c => challenge_participant_id(membername, challenge_id),
          :url__c => params[:link],
          :type__c => params[:type],
          :comments__c => params[:comments]
      }
    }         
    post_apex_rest('/submissions', options)
  end  

  def self.delete_url_or_file_submission(access_token, submission_id)
    set_header_token(access_token)
    put_apex_rest("/submissions/#{submission_id}", {'deleted__c' => 'true'})
  end      

  private

    def self.challenge_participant_id(membername, challenge_id)
      query_salesforce(access_token, 
        "select id from challenge_participant__c where member__r.name = '#{membername}' 
        and challenge__r.challenge_id__c = '#{challenge_id}'").first['id']
    end

end