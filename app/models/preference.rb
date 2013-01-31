class Preference < Salesforce

	def self.all(access_token, membername)

    query_salesforce(access_token, "select Id, Do_not_Notify__c, Event__c, 
    	Notification_Method__c from Notification_Settings__c 
    	where member__r.name = '#{membername}'")

	end

	def self.update(access_token, membername, params)
		puts "========== params #{params.to_yaml}"
	end

end