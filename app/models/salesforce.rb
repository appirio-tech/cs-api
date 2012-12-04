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
  # Makes generic 'get' apex rest calls
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
  # Makes generic 'post' apex rest calls to create records in salesforce
  # * *Args*    :
  #   - sobject -> the sObject to create
  #   - params -> hash with the fields and values to be used to create
  # * *Returns* :
  #   - a hash containing the following keys: success, message
  # * *Raises* :
  #   - ++ ->
  #  
  def self.post_apex_rest(sobject, params)
    options = {
      :body => params.to_json
    }

    begin
      post_results = Forcifier::JsonMassager.deforce_json(post(ENV['SFDC_REST_API_URL']+
        "/sobjects/#{sobject}", options))
      {:success => true, :message => post_results['id']}
    rescue Exception => e
      {:success => false, :message => post_results}
    end     
  end  

  #
  # Makes generic 'delete' apex rest calls to delete a records in salesforce
  # * *Args*    :
  #   - sobject -> the sObject to create
  #   - id -> the id of the record to delete
  # * *Returns* :
    #   - a hash containing the following keys: success, message
  # * *Raises* :
  #   - ++ ->
  #  
  def self.delete_apex_rest(sobject, id)
    delete_results = Forcifier::JsonMassager.deforce_json(delete(ENV['SFDC_REST_API_URL']+
      "/sobjects/#{sobject}/#{id}"))
    # a return value of null means a successful delete
    if delete_results
      {:success => false, :message => delete_results.first['message']}
    else
      {:success => true, :message => 'Record successfully deleted.'}
    end
  end    

end