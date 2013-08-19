class Preference < Salesforce

  def self.all(access_token, membername)
    set_header_token(access_token) 
    get_apex_rest("/notifications/preferences/#{membername}")
  end

  def self.update(access_token, membername, params)
    set_header_token(access_token) 
    options = { :body => params['preferences'] }  
    results = put(ENV['SFDC_APEXREST_URL'] + "/notifications/preferences/#{membername}", options)   
    {:success => results['Success'].to_bool, :message => results['Message']} 
  end

end