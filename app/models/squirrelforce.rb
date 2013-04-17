require 'member'
require 'bunny'

class Squirrelforce  < Salesforce

	def self.unleash_squirrel(access_token, submission_deliverable_id)

		deliverable = query_salesforce(access_token, "select Id, Name, Language__c, 
			URL__c, Challenge_Participant__c, Challenge_Participant__r.Member__r.Name,
			Challenge_Participant__r.Challenge__r.Challenge_Id__c
			from Submission_Deliverable__c where id = '#{submission_deliverable_id}'")	

		#rename the key from laugnage to type for rabbitmq
		deliverable = Forcifier::JsonMassager.deforce_json(deliverable.first)
		# rabbit expects a key called 'type' instead of language
		deliverable.rename_key!('language','type')
		# make the membername a little easier to work with
		deliverable['membername'] = deliverable['challenge_participant__r']['member__r']['name']
		deliverable['challenge_id'] = deliverable['challenge_participant__r']['challenge__r']['challenge_id']
		# remove the old key
		deliverable.remove_key!('challenge_participant__r')

		b = Bunny.new ENV['CLOUDAMQP_URL']
		b.start
		q = b.queue(ENV['SQUIRRELFORCE_QUEUE'])
		q.publish(deliverable.to_json)
		b.stop
		deliverable
  rescue Exception => e
    Rails.logger.fatal "[FATAL][SQUIRRELFORCE] Error unleasing squirrel for #{submission_deliverable_id}: #{e.message}" 
	end

	def self.reserve_server(access_token, membername)
		set_header_token(access_token) 
		  
		fetch_server_results = query_salesforce(access_token, "select Id, Name, Installed_Services__c, Instance_URL__c, 
			Operating_System__c, Password__c, Platform__c, Repo_Name__c,
			Supported_Programming_Language__c, Username__c from Server__c where 
			platform__c = 'Salesforce.com' and Reserved_text__c = 'FREE'")

		unless fetch_server_results.empty?
			# select a random server
			server = Forcifier::JsonMassager.deforce_json(fetch_server_results.sample)
			# add a new reservation for this server
=begin			
			create_in_salesforce(access_token, 'Reservation__c', {'Reserved_Server__c' => server['id'], 
				'Reserved_Member__c' => Member.salesforce_member_id(access_token, membername), 
				'Start_Date__c' => DateTime.now})
=end				
			{:success => true, :message => 'Server successfully reserved.', :server => server}
		else
			{:success => false, :message => 'No available server with requested specifications.'}
		end

	end

	def self.release_server(access_token, reservation_id)
		destroy_in_salesforce(access_token, 'Reservation__c', reservation_id)
	end	

	def self.papertrail_system(participant_id)
  	auth = {
  		:username => ENV['PAPERTRAIL_DIST_USERNAME'], 
  		:password => ENV['PAPERTRAIL_DIST_PASSWORD']
  	}
		HTTParty::get("https://papertrailapp.com/api/v1/distributors/systems/#{participant_id}",
			:basic_auth => auth).parsed_response
	end		

end