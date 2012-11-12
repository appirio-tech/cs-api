class Tos < Salesforce

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