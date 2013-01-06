require 'health_check'

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

  def self.find(access_token, challenge_id, for_admin)  
    set_header_token(access_token) 
    fetch_comments = for_admin ? '' : '?comments=true'
    challenge = get_apex_rest("/challenges/#{challenge_id}#{fetch_comments}").first
    if for_admin && !challenge.nil?
      challenge.remove_key!('challenge_participants__r')
      challenge['challenge_reviewers__r'] = query_salesforce(access_token, 
        "select id, member__r.name from challenge_reviewer__c 
        where challenge__r.challenge_id__c = '#{challenge_id}'")
      challenge['challenge_comment_notifiers__r'] = query_salesforce(access_token, 
        "select id, member__r.name from challenge_comment_notifier__c 
        where challenge__r.challenge_id__c = '#{challenge_id}'")
    end
    challenge
  end 

  def self.find_for_admin(access_token, challenge_id)  
    set_header_token(access_token) 
    get_apex_rest("/challenges/#{challenge_id}").first
  end 	

  def self.participants(access_token, challenge_id)  
    set_header_token(access_token) 
    get_apex_rest("/participants?challengeid=#{challenge_id}&fields=Member__r.Profile_Pic__c,Member__r.Name,Member__r.Total_Wins__c,Member__r.summary_bio__c,Status__c,has_submission__c&limit=250&orderby=member__r.name")
  end  	      

  def self.comments(access_token, challenge_id)  
    set_header_token(access_token) 
    get_apex_rest("/comments/#{challenge_id}")
  end  	 

  def self.comment(access_token, data)
    options = {
      :body => {
          :username => data[:membername],
          :challenge => data[:challenge_id],
          :comment => data[:comments],
          :replyto => data[:reply_to]
      }
    }
    results = post(ENV['SFDC_APEXREST_URL'] + "/comments", options)    
    {:success => results['Success'], :message => results['Message']}
  end    

  def self.all(access_token, open, category, order_by, limit=25, offset=0) 
    set_header_token(access_token)   
    qry_category = category.nil? ? '' : "&category=#{esc category}"    
    get_apex_rest("/challengesearch?fields=Id,Challenge_Id__c,Name,Description__c,Total_Prize_Money__c,Challenge_Type__c,Days_till_Close__c,Registered_Members__c,Start_Date__c,End_Date__c,Is_Open__c,Community__r.Name&open=#{open}&orderby=#{esc order_by}&limit=#{limit}&offset=#{offset}"+qry_category)
  end

  def self.recent(access_token, limit, offset)  
    query_salesforce(access_token, "SELECT Blog_URL__c, Name, Description__c, End_Date__c, Challenge_Id__c, License_Type__r.Name, Source_Code_URL__c,
        Total_Prize_Money__c, Top_Prize__c, (SELECT Money_Awarded__c,Place__c,Member__c,
        Member__r.Name, Points_Awarded__c,Score__c,Status__c FROM Challenge_Participants__r where Has_Submission__c = true), 
        (Select Name, Category__c, Display_Name__c From Challenge_Categories__r) 
        FROM Challenge__c where Status__c = 'Winner Selected' Order By End_Date__c DESC LIMIT #{limit} OFFSET #{offset}")
  end  

  def self.salesforce_id(access_token, challenge_id) 
    query_salesforce(access_token, "select id from challenge__c where challenge_id__c = '#{challenge_id}'").first['id']
  rescue Exception => e  
    nil
  end  

  # run via rake task, updates all currently open public challenge with 
  # probability of success
  def self.run_health_check

    # get an oauth token
    oauth_token = access_token

    # get all of the public, open challenges
    Challenge.all(oauth_token, 'true', nil, 'name').each do |c|

      # get the comments for the challenge
      comments = Forcifier::JsonMassager.deforce_json(query_salesforce(access_token, 
        "select id, member__r.email__c from challenge_comment__c 
        where challenge__c = '#{c['id']}'"))      
  
      #update the health status back in salesforce
      update_in_salesforce(oauth_token, 'Challenge__c', {'Id' => c['id'], 
        'health__c' => HealthCheck.status(c, comments)})
  
    end

  end      

end