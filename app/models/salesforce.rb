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

  # perhaps move this to it's own class
  def self.make_pretty(json)
    #puts "starting pretty process...."
    ary = []
    json.each do |record|
      pretty_hash = {}
      record.to_hash.each_pair do |k,v|
        pretty_hash.merge!({k.gsub('__c','').downcase => v}) 
        if k.include? '__r'
          pretty_hash.update(k.downcase => make_pretty_related(v))
        end  
      end
      ary << pretty_hash
    end
    ary
  end

  def self.make_pretty_related(json)
    pretty_hash = {}
    json.each do |k,v|
      pretty_hash.merge!({k.gsub('__c','').downcase => v})     
      if v.kind_of?(Array)
        pretty_hash.update(k.downcase => make_pretty(v))
      end        
    end
    pretty_hash
  end  

  def self.soql_query(soql)
    get(ENV['SFDC_REST_API_URL']+"/query?q=#{esc soql}")
  end

end