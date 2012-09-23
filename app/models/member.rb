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

	def self.recommendations(access_token, membername, fields) 
    set_header_token(access_token)    
    make_pretty(get(ENV['SFDC_APEXREST_URL'] +  "/recommendations?fields=#{esc fields}&search=#{esc membername}") )
	end
  
  def self.find_by_username(access_token, membername, fields)
    set_header_token(access_token)    
    make_pretty(get(ENV['SFDC_APEXREST_URL']+"/members/#{esc membername}?fields=#{esc fields}"))
  end

  def  self.hello
    "hello world"
  end  

end