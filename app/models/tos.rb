class Tos < Salesforce

  #
  # Returns all TOS records
  # * *Args*    :
  #   - access_token -> the oauth token to use
  # * *Returns* :
  #   - JSON a collection of TOS objects
  # * *Raises* :
  #   - ++ ->
  # 
  def self.all(access_token) 
    set_header_token(access_token)   
    query_results = soql_query("select id, name, terms__c, default_tos__c 
      from terms_of_service__c order by name")
    Forcifier::JsonMassager.deforce_json(query_results['records'])
  end  

  #
  # Returns a specific TOS by ID using the SFDC REST API.
  # * *Args*    :
  #   - access_token -> the oauth token to use
  #   - id -> the salesforce id of the tos to return
  # * *Returns* :
  #   - A Terms_of_Service__c object
  # * *Raises* :
  #   - ++ ->
  # 
  def self.find(access_token, id) 
    set_header_token(access_token)   
    Forcifier::JsonMassager.deforce_json(get(ENV['SFDC_REST_API_URL'] + 
    	"/sobjects/terms_of_service__c/#{id}"))
  end

end