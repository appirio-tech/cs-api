class Member < Salesforce

  def self.all(access_token, fields, order_by) 
    set_header_token(access_token)   
    make_pretty(get(ENV['SFDC_APEXREST_URL'] +  "/members?fields=#{esc fields}&orderby=#{esc order_by}"))
  end

  def self.search(access_token, fields, membername)
    set_header_token(access_token)    
    make_pretty(get(ENV['SFDC_APEXREST_URL'] +  "/members?fields=#{esc fields}&search=#{esc membername}"))
  end

  def self.challenges(access_token, membername)
    set_header_token(access_token)    
    make_pretty(get(ENV['SFDC_APEXREST_URL'] +  "/members/#{esc membername}/challenges"))
  end

  def self.find_by_username(access_token, membername, fields)
    set_header_token(access_token)    
    make_pretty(get(ENV['SFDC_APEXREST_URL']+"/members/#{esc membername}?fields=#{esc fields}"))
  end

  def self.payments(access_token, membername, fields, order_by) 
    set_header_token(access_token)    
    query_results = soql_query("select "+ fields +" from payment__c where member__r.name = '" + 
      membername + "' order by " + order_by)
    make_pretty(query_results['records'])
  end    

  def self.recommendations(access_token, membername, fields) 
    set_header_token(access_token)    
    make_pretty(get(ENV['SFDC_APEXREST_URL'] +  "/recommendations?fields=#{esc fields}&search=#{esc membername}"))
  end  

  def self.recommendation_create(access_token, for_member, from_member, comments)
    set_header_token(access_token)  

    options = {
      :body => {
        :recommendation_for_username => for_member,
        :recommendation_from_username => from_member,
        :recommendation_text => comments
      }
    }
    results = post(ENV['SFDC_APEXREST_URL']+'/recommendations', options)
    { :success => results['Success'], :message => results['Message'] }
  end 

end