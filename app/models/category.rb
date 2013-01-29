class Category < Salesforce

  def self.all(access_token) 
		query_salesforce(access_token, "select name from category__c 
			where active__c = true order by name").map { |t| t.name }
  end

end