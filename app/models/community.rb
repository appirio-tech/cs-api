class Community  < Salesforce

	def self.all(access_token)
		query(access_token, "select name, community_id__c, about__c, members__c from community__c order by name")
	end

	def self.find(access_token, community_id)
    set_header_token(access_token)
    get_apex_rest("/communities/#{community_id}")
	end	

	def self.add_member(access_token, params)
		# get the id for the community
		id = query(access_token, "select id from community__c where community_id__c = '#{params[:community_id]}'").first.id
		# add the community member record
		create_results = create(access_token, 'Community_Member__c', 
			{'User__c' => Member.salesforce_user_id(access_token, params[:membername]), 
			'Community__c' => id})
    {:success => create_results[:success], :message => create_results[:message]}      
  rescue Exception => e
    puts "[FATAL][Community] Add community member exception: #{e.message}" 
    {:success => false, :message => e.message}    
	end		

end