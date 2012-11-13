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
    get(ENV['SFDC_REST_API_URL']+"/query?q=#{esc soql}")
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

end