class Category < Salesforce

  def self.all(access_token) 
    set_header_token(access_token)   
    request_url  = ENV['SFDC_APEXREST_URL'] + "/categories?fields=name,color__c&orderby=display_order__c&search=true"
    Forcifier::JsonMassager.deforce_json(get(request_url))
  end

end