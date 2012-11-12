class Challenge < Salesforce

  def self.create(access_token, data)
    set_header_token(access_token) 
    # enforce the keys of each hash but not the hash key itself
    data['challenge'].each do |key|
      data['challenge'][key.first] = Forcifier::JsonMassager.enforce_json(key.second)
    end
    options = { :body => data.to_json }  
    results = post(ENV['SFDC_APEXREST_URL'] + "/admin/challenges", options)
    {:success => results['success'], :challenge_id => results['challengeId'], 
      :errors => results['errors']}
  end

  def self.update(access_token, challenge_id, data)
    set_header_token(access_token) 
    # enforce the keys of each hash but not the hash key itself
    data['challenge'].each do |key|
      data['challenge'][key.first] = Forcifier::JsonMassager.enforce_json(key.second)
    end
    # add the challenge id to the json
    data['challenge']['detail']['challenge_id__c'] = challenge_id
    options = { :body => data.to_json }  
    results = put(ENV['SFDC_APEXREST_URL'] + "/admin/challenges", options)
    {:success => results['success'], :challenge_id => results['challengeId'], 
      :errors => results['errors']}
  end  

  def self.find(access_token, challenge_id)  
    set_header_token(access_token) 
    Forcifier::JsonMassager.deforce_json(get(ENV['SFDC_APEXREST_URL'] +
    	"/challenges/#{challenge_id}?comments=true")).first
  end  	

  def self.participants(access_token, challenge_id)  
    set_header_token(access_token) 
    Forcifier::JsonMassager.deforce_json(get(ENV['SFDC_APEXREST_URL'] +
    	"/participants?challengeid=#{challenge_id}&fields=Member__r.Profile_Pic__c,Member__r.Name,Member__r.Total_Wins__c,Member__r.summary_bio__c,Status__c,has_submission__c&limit=250&orderby=member__r.name"))
  end  	      

  def self.comments(access_token, challenge_id)  
    set_header_token(access_token) 
    Forcifier::JsonMassager.deforce_json(get(ENV['SFDC_APEXREST_URL'] +
    	"/comments/#{challenge_id}"))
  end  	   

  def self.all(access_token, open, category, order_by) 
    set_header_token(access_token)   
    qry_category = category.nil? ? '' : "&category=#{esc category}"    
    Forcifier::JsonMassager.deforce_json(get(ENV['SFDC_APEXREST_URL'] +
    	"/challengesearch?fields=Id,Challenge_Id__c,Name,Description__c,Total_Prize_Money__c,Challenge_Type__c,Days_till_Close__c,Registered_Members__c,Start_Date__c,End_Date__c,Is_Open__c,Community__r.Name&open=#{open}&orderby=#{esc order_by}"+qry_category))
  end

  def self.recent(access_token)  
    set_header_token(access_token) 
    Forcifier::JsonMassager.deforce_json(get(ENV['SFDC_APEXREST_URL'] +
    	'/challenges/recent'))
  end  

end