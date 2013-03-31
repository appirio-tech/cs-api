require 'health_check'

class Challenge < Salesforce

  def self.create(access_token, data)
    set_header_token(access_token)
    # enforce the keys of each hash but not the hash key itself
    data['challenge'].each do |key|
      data['challenge'][key.first] = Forcifier::JsonMassager.enforce_json(key.second)
    end
    options = { :body => data.to_json }  
    results = post(ENV['SFDC_APEXREST_URL_V1'] + "/admin/challenges", options)
    {:success => results['success'], :challenge_id => results['challengeId'], 
      :errors => results['errors']}    
  rescue Exception => e
    {:success => 'false', :challenge_id => challenge_id, :errors => e.message} 
  end

  def self.update(access_token, challenge_id, data)
    set_header_token(access_token) 
    # enforce the keys of each hash but not the hash key itself
    data['challenge'].each do |key|
      data['challenge'][key.first] = Forcifier::JsonMassager.enforce_json(key.second)
    end
    options = { :body => data.to_json }  
    results = put(ENV['SFDC_APEXREST_URL_V1'] + "/admin/challenges", options)
    {:success => results['success'], :challenge_id => challenge_id, 
      :errors => results['errors']}
  rescue Exception => e
    puts results.to_yaml
    puts e.to_yaml
    {:success => 'false', :challenge_id => challenge_id, :errors => e.message} 
  end   

  def self.update_original(access_token, challenge_id, data)
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
      challenge['assets__r'] = query_salesforce(access_token, 
        "select id, name, key__c, filename__c from asset__c 
        where challenge__r.challenge_id__c = '#{challenge_id}'")      
    end

    # check for sfdc internal errors
    unless challenge.nil?
      return nil if challenge.has_key?('errorcode')
    end

    challenge
  end 

  def self.find_for_admin(access_token, challenge_id)  
    set_header_token(access_token) 
    get_apex_rest("/challenges/#{challenge_id}").first
  end 	

  def self.participants(access_token, challenge_id)  
    set_header_token(access_token) 
    get_apex_rest("/participants?challengeid=#{challenge_id}&fields=Member__r.Profile_Pic__c,Member__r.Name,Member__r.Total_Wins__c,Member__r.Total_Public_Money__c,Member__r.Country__c,Member__r.summary_bio__c,Status__c,has_submission__c&limit=250&orderby=member__r.name")
  end  	      

  def self.submission_deliverables(access_token, challenge_id)  
    set_header_token(access_token) 
    get_apex_rest("/submissions?challengeid=#{challenge_id}&fields=id,name,challenge__r.name,url__c,comments__c,type__c,username__c,challenge_participant__r.place__c&orderby=username__c")
  end  

  def self.scorecard(access_token, challenge_id)  
    set_header_token(access_token) 
    get_apex_rest("/scorecard/#{challenge_id}/questions")
  end          

  def self.scorecards(access_token, challenge_id)  
    set_header_token(access_token) 
    get_apex_rest("/challenges/#{challenge_id}/scorecards?fields=id,name,member__r.name,member__r.profile_pic__c,member__r.country__c,challenge__c,money_awarded__c,prize_awarded__c,place__c,score__c,submitted_date__c")
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

  def self.all(access_token, open, technology, platform, category, order_by, limit=25, offset=0) 
    params = {:open => open, :orderby => order_by, :limit => limit, :offset => offset,
      :fields => 'Id,Challenge_Id__c,Name,Description__c,Total_Prize_Money__c,Challenge_Type__c,Days_till_Close__c,Registered_Members__c,Participating_Members__c,Start_Date__c,End_Date__c,Is_Open__c,Community__r.Name,Community__r.Community_Id__c'}
    params.merge!(:technology => technology) if technology
    params.merge!(:platform => platform) if platform
    params.merge!(:category => category) if category
    set_header_token(access_token)      
    get_apex_rest("/challengeslist?#{params.to_param}")
  end

  #
  # Performs a simple, name-only, keyword search against open challenges
  # * *Args*    :
  #   - access_token -> the oauth token to use
  #   - keyword -> the keyword to search for
  # * *Returns* :
  #   - JSON an array of challenges 
  # * *Raises* :
  #   - ++ ->
  #  
  def self.search(access_token, keyword)  
    query_salesforce(access_token, "select name, end_date__c, total_prize_money__c, 
      registered_members__c, challenge_id__c, challenge_type__c, id, start_date__c, 
      description__c, days_till_close__c, (select id, display_name__c 
      from challenge_categories__r) from challenge__c where name like '%#{keyword}%' order by name")
  end    

  def self.recent(access_token, limit, offset)  
    query_salesforce(access_token, "SELECT Blog_URL__c, Blogged__c, Auto_Blog_URL__c, Name, challenge_type__c, Description__c, End_Date__c, Challenge_Id__c, License_Type__r.Name, Source_Code_URL__c,
        Total_Prize_Money__c, Top_Prize__c,registered_members__c, participating_members__c, (SELECT Money_Awarded__c,Place__c,Member__c,
        Member__r.Name, Points_Awarded__c,Score__c,Status__c FROM Challenge_Participants__r where Has_Submission__c = true), 
        (Select Name, Category__c, Display_Name__c From Challenge_Categories__r), (Select name__c From Challenge_Platforms__r), 
        (Select name__c From Challenge_Technologies__r)   
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
    Challenge.all(oauth_token, 'true', nil, nil, nil, 'name', 1000, 0).each do |c|

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