class Platform< Salesforce

  def self.all(access_token) 
		query_salesforce(access_token, "select name from platform__c 
  		where active__c = true order by name").map { |t| t.name }
  end

end