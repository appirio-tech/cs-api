class Member < Salesforce

  #
  # Returns a collection of all members for specified the fields and ordered results
  # * *Args*    :
  #   - access_token -> the oauth token to use
  #   - fields -> the fields to return in the JSON. The default fields
  # to return are in the application_controller.
  #   - order_by -> the field to order the results by. Defaults to 'total_wins__c'
  # in the members_controller  
  #   - limit -> the number of records to return
  #   - offset -> specifies the starting row offset into the result set 
  # returned by your query
  # * *Returns* :
  #   - JSON containing a collection of members
  # * *Raises* :
  #   - ++ ->
  #   
  def self.all(access_token, fields, order_by, limit, offset) 
    set_header_token(access_token) 
    get_apex_rest("/members?fields=#{esc fields}&orderby=#{esc order_by}&limit=#{limit}&offset=#{offset}")
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
  # TODO - implement a limit & offset -- challenge in progress (1927)
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
  # Returns all of the challenges the member has been judge, 
  # contact or notifier
  # * *Args*    :
  #   - access_token -> the oauth token to use
  #   - membername -> the member to return the challenges for
  # * *Returns* :
  #   - JSON containing a collection of challenges
  # * *Raises* :
  #   - ++ ->
  #  
  def self.challenges_as_admin(access_token, membername) 
    set_header_token(access_token)
    get_apex_rest("/members/#{esc membername}/admin/challenges")
  rescue Exception => e
    puts "[FATAL][Member] Error fetching admin challenges for #{membername}: #{e.message}"     
    raise e.message
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
    query_salesforce(access_token, "select "+ fields +" from payment__c where member__r.name = '" + 
      membername + "' order by " + order_by)
  end    

  #
  # Returns the login type for a member
  # * *Args*    :
  #   - access_token -> the oauth token to use
  #   - membername -> the member to return the login type for
  # * *Returns* :
  #   - the login_managed_by value 
  # * *Raises* :
  #   - ++ ->
  #  
  def self.login_type(access_token, membername)  
    query_salesforce(access_token, "select login_managed_by__c from member__c 
      where name = '#{membername}'").first['login_managed_by']
  rescue
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

  #
  # Returns a collection of referral objects for a member
  # * *Args*    :
  #   - access_token -> the oauth token to use
  #   - membername -> the member to return the recommendations for   
  # * *Returns* :
  #   - JSON containing a collection of recommendations
  # * *Raises* :
  #   - ++ ->
  #  
  def self.referrals(access_token, membername) 
    set_header_token(access_token)    
    get_apex_rest("/referrals/#{esc membername}")
  end  

  #
  # Returns the salesforce member id for a member
  # * *Args*    :
  #   - access_token -> the oauth token to use
  #   - membername -> the member to return the id for
  # * *Returns* :
  #   - salesforce member id
  # * *Raises* :
  #   - ++ ->
  #  
  def self.salesforce_member_id(access_token, membername) 
    get_member(access_token, membername)['id']
  end     

  #
  # Returns the salesforce user id for a member
  # * *Args*    :
  #   - access_token -> the oauth token to use
  #   - membername -> the member to return the id for
  # * *Returns* :
  #   - salesforce user id
  # * *Raises* :
  #   - ++ ->
  #  
  def self.salesforce_user_id(access_token, membername)  
    get_member(access_token, membername)['sfdc_user']
  end     

  private 

    def self.get_member(access_token, membername)
      results = query_salesforce(access_token, "select id, sfdc_user__c 
        from member__c where name = '#{membername}'")
      raise "Member #{membername} not found." if results.empty?
      results.first
    end

end