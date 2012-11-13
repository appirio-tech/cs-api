class Member < Salesforce

  #
  # Returns a collection of all members for specified the fields and ordered results
  # * *Args*    :
  #   - access_token -> the oauth token to use
  #   - fields -> the fields to return in the JSON. The default fields
  # to return are in the application_controller.
  #   - order_by -> the field to order the results by. Defaults to 'total_wins__c'
  # in the members_controller  
  # * *Returns* :
  #   - JSON containing a collection of members
  # * *Raises* :
  #   - ++ ->
  #   
  # TODO - implement a limit   
  def self.all(access_token, fields, order_by) 
    set_header_token(access_token) 
    get_apex_rest("/members?fields=#{esc fields}&orderby=#{esc order_by}")
  end

  #
  # Updates a member in sfdc
  # * *Args*    :
  #   - access_token -> the oauth token to use
  #   - membername -> the member to update
  #   - params -> hash of values to be updated
  # * *Returns* :
  #   - a hash containing the following keys: success, message
  # * *Raises* :
  #   - ++ ->
  #   
  def self.update(access_token, membername, params)
    set_header_token(access_token)   
    results = put(ENV['SFDC_APEXREST_URL'] + "/members/#{esc membername}",:query => params)
    {:success => results['Success'], :message => results['Message']}
  end  
  
  #
  # Performs a keyword search (like 'keyword%') for members in sfdc
  # * *Args*    :
  #   - access_token -> the oauth token to use
  #   - keyword -> the search keyword
  #   - fields -> the fields to return in the JSON. The default fields
  # to return are in the application_controller.
  # * *Returns* :
  #   - JSON containing a collection of members
  # * *Raises* :
  #   - ++ ->
  #   
  # TODO - implement a limit
  def self.search(access_token, keyword, fields)
    set_header_token(access_token)    
    get_apex_rest("/members?fields=#{esc fields}&search=#{esc keyword}")
  end

  #
  # Returns all data for the specified user. This includes their member info,
  # challenges they've been involved in and their recommendations
  # * *Args*    :
  #   - access_token -> the oauth token to use
  #   - membername -> the member to return all info for
  #   - fields -> the fields to return in the JSON. The default fields
  # to return are in the members_controller.  
  # * *Returns* :
  #   - a hash containing the following keys: member, challenges, recommendations
  # * *Raises* :
  #   - ++ ->
  #  
  def self.find_by_membername(access_token, membername, fields)
    set_header_token(access_token) 
    get_apex_rest("/members/#{esc membername}?fields=#{esc fields}")
  end

  #
  # Returns a collection of all challenges a member has ever been involved in
  # * *Args*    :
  #   - access_token -> the oauth token to use
  #   - membername -> the member to return the challenges for
  # * *Returns* :
  #   - JSON containing a collection of challenges
  # * *Raises* :
  #   - ++ ->
  #  
  def self.challenges(access_token, membername)
    set_header_token(access_token)
    get_apex_rest("/members/#{esc membername}/challenges")
  end

  #
  # Returns a collection of all payments for a member
  # * *Args*    :
  #   - access_token -> the oauth token to use
  #   - membername -> the member to return the payments for
  #   - fields -> the fields to return in the JSON. The default fields
  # to return are in the members_controller.    
  #   - order_by -> the field to order the results by. The default field
  # is in the members_controller.     
  # * *Returns* :
  #   - JSON containing a collection of payments
  # * *Raises* :
  #   - ++ ->
  #  
  def self.payments(access_token, membername, fields, order_by) 
    set_header_token(access_token)    
    query_results = soql_query("select "+ fields +" from payment__c where member__r.name = '" + 
      membername + "' order by " + order_by)
    Forcifier::JsonMassager.deforce_json(query_results['records'])
  end    

  #
  # Returns a collection of all recommendations for a member
  # * *Args*    :
  #   - access_token -> the oauth token to use
  #   - membername -> the member to return the recommendations for
  #   - fields -> the fields to return in the JSON. The default fields
  # to return are in the members_controller.     
  # * *Returns* :
  #   - JSON containing a collection of recommendations
  # * *Raises* :
  #   - ++ ->
  #  
  def self.recommendations(access_token, membername, fields) 
    set_header_token(access_token)    
    get_apex_rest("/recommendations?fields=#{esc fields}&search=#{esc membername}")
  end  

  #
  # Creates a new recommendation in sfdc
  # * *Args*    :
  #   - access_token -> the oauth token to use
  #   - for_member -> the member to create the recommendation for
  #   - from_member -> the member that is submiting the recommendation
  #   - comments -> the text of the recommendation
  # * *Returns* :
    #   - a hash containing the following keys: success, message
  # * *Raises* :
  #   - ++ ->
  #  
  def self.recommendation_create(access_token, for_member, from_member, comments)
    set_header_token(access_token)  

    options = {
      :body => {
        :recommendation_for_username => for_member,
        :recommendation_from_username => from_member,
        :recommendation_text => comments
      }
    }
    results = post(ENV['SFDC_APEXREST_URL']+'/recommendations', options)
    { :success => results['Success'], :message => results['Message'] }
  end 

end