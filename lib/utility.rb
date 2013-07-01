class Utility < Salesforce

  def self.run(access_token)

    set_header_token(access_token)   
    request_url  = 'https://na12.salesforce.com/services/apexrest/misc-util'
    get(request_url)

  end

end