class Category < Salesforce

  def self.all(access_token) 
    set_header_token(access_token)   
    get_apex_rest("/categories?fields=name,color__c&orderby=display_order__c&search=true")
  end

end