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

  def self.access_token(type=:public)
    client = Restforce.new :username => ENV['SFDC_PUBLIC_USERNAME'],
      :password       => ENV['SFDC_PUBLIC_PASSWORD'],
      :client_id      => ENV['DATABASEDOTCOM_CLIENT_ID'],
      :client_secret  => ENV['DATABASEDOTCOM_CLIENT_SECRET'],
      :host           => ENV['DATABASEDOTCOM_HOST']
    client.authenticate!.access_token
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
  def self.get_apex_rest(url_string, version='v.9')
    Forcifier::JsonMassager.deforce_json(get(ENV['SFDC_APEXREST_ROOT_URL']+"/#{version}#{url_string}"))
  end  

  #
  # Makes generic 'post' to CloudSpokes Apex REST services
  # * *Args*    :
  #   - url_string -> the string to be appended to teh end of the url
  # * *Returns* :
    #   - a results object
  # * *Raises* :
  #   - ++ ->
  #  
  def self.post_apex_rest(url_string, options)
    Forcifier::JsonMassager.deforce_json(post(ENV['SFDC_APEXREST_URL']+"#{url_string}", options))
  end    

  #
  # Makes generic 'put' to CloudSpokes Apex REST services
  # * *Args*    :
  #   - url_string -> the string to be appended to teh end of the url
  # * *Returns* :
    #   - a results object
  # * *Raises* :
  #   - ++ ->
  #  
  def self.put_apex_rest(url_string, params={})
    Forcifier::JsonMassager.deforce_json(put(ENV['SFDC_APEXREST_URL']+"#{url_string}?#{params.to_param}"))
  end   

  #
  # Makes generic 'get' to CloudSpokes Apex REST services
  # and returns success
  # * *Args*    :
  #   - url_string -> the string to be appended to teh end of the url
  # * *Returns* :
    #   - true/false
  # * *Raises* :
  #   - ++ ->
  #  
  def self.get_apex_rest_return_boolean(url_string)
    success = false
    success = true if get(ENV['SFDC_APEXREST_URL'] + 
      "#{url_string}")['Success'].eql?('true')  
    success
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
  # Updates a new record in salesforce
  # * *Args*    :
  #   - access_token -> the oauth token to use  
  #   - params -> the hash of values for the new record
  # * *Returns* :
    #   - new record id
  # * *Raises* :
  #   - ++ ->
  #  
  def self.update_in_salesforce(access_token, sobject, params)
    {:success => restforce_client(access_token).update!(sobject, params), :message => ''}      
  rescue Exception => e
    puts "[FATAL][Salesforce] Update exception: #{e.message}" 
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
  def self.picklist_values(access_token, sobject, field)
    restforce_client(access_token).picklist_values(sobject, field)
  rescue Exception => e
    puts "[FATAL][Salesforce] Exception getting picklist values: #{e.message}" 
    {:success => false, :message => e.message}   
  end   

end