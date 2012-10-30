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

end