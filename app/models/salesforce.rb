require 'uri' 

class Salesforce

  include HTTParty

  format :json
  headers 'Content-Type' => 'application/json'	

  def self.esc(str)
    URI.escape(str)
  end
  
  def self.set_header_token(access_token)
    headers 'Authorization' => "OAuth #{access_token}" 
  end  

  def self.soql_query(soql)
    begin
      get(ENV['SFDC_REST_API_URL']+"/query?q=#{esc soql}")
    rescue Exception => e
      nil
    end     
  end

  #
  # Returns a restforce client from an access_token
  # * *Args*    :
  #   - access_token -> the oauth token to use
  # * *Returns* :
    #   - Restforce client
  # * *Raises* :
  #   - ++ ->
  #  
  def self.restforce_client(access_token)
    Restforce.new :oauth_token => access_token,
      :instance_url  => ENV['SFDC_INSTANCE_URL']
  end

  #
  # Makes generic 'get' to CloudSpokes Apex REST services
  # * *Args*    :
  #   - url_string -> the string to be appended to teh end of the url
  # * *Returns* :
    #   - a results object
  # * *Raises* :
  #   - ++ ->
  #  
  def self.get_apex_rest(url_string)
    Forcifier::JsonMassager.deforce_json(get(ENV['SFDC_APEXREST_URL']+"#{url_string}"))
  end  

  #
  # Performs a soql query against salesforce
  # * *Args*    :
  #   - access_token -> the oauth token to use
  #   - soql -> the soql query
  # * *Returns* :
    #   - a results object
  # * *Raises* :
  #   - ++ ->
  #  
  def self.query_salesforce(access_token, soql)
    Forcifier::JsonMassager.deforce_json(restforce_client(access_token).query(soql))
  rescue Exception => e
    puts "[FATAL][Salesforce] Query exception: #{soql} -- #{e.message}" 
    nil
  end  

  #
  # Creates a new record in salesforce
  # * *Args*    :
  #   - access_token -> the oauth token to use  
  #   - params -> the hash of values for the new record
  # * *Returns* :
    #   - new record id
  # * *Raises* :
  #   - ++ ->
  #  
  def self.create_in_salesforce(access_token, sobject, params)
    {:success => true, :message => restforce_client(access_token).create!(sobject, params)}      
  rescue Exception => e
    puts "[FATAL][Salesforce] Create exception: #{e.message}" 
    {:success => false, :message => e.message}    
  end

  #
  # Makes generic destroy to delete a records in salesforce
  # * *Args*    :
  #   - sobject -> the sObject to create
  #   - id -> the id of the record to delete
  # * *Returns* :
    #   - a hash containing the following keys: success, message
  # * *Raises* :
  #   - ++ ->
  #  
  def self.destroy_in_salesforce(access_token, sobject, id)
    restforce_client(access_token).destroy!(sobject, id)
    {:success => true, :message => 'Record successfully deleted.'} 
  rescue Exception => e
    puts "[FATAL][Salesforce] Destroy exception for Id #{id}: #{e.message}" 
    {:success => false, :message => e.message}   
  end 

end