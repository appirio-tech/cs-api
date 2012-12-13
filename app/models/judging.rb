require 'member'
require 'challenge'

class Judging  < Salesforce

	def self.queue(access_token)
		query_salesforce(access_token, "select id, challenge_id__c, name, status__c, number_of_reviewers__c, end_date__c, winner_announced__c,
			(select display_name__c from challenge_categories__r) 
			from Challenge__c where community_judging__c = true and is_open__c = 'true' 
			and number_of_reviewers__c < 2 order by end_date__c")
	end

	def self.add(access_token, challenge_id, membername)

		# make sure the challenge is in the right status
		challenge_status = query_salesforce(access_token, "select id from challenge__c where status__c IN ('Planned','Created') 
			and challenge_id__c = '#{challenge_id}'")		
		# make sure all of the judging spots haven't been filled yet
		total_judges = query_salesforce(access_token, "select id from challenge_reviewer__c 
			where challenge__r.challenge_id__c = '#{challenge_id}'")		
		# find out if the member is a judge already
		current_judge = query_salesforce(access_token, "select id from challenge_reviewer__c where member__r.name = '#{membername}' 
			and challenge__r.challenge_id__c = '#{challenge_id}'")
		# find out if the member is a participant already
		current_participant = query_salesforce(access_token, "select id from challenge_participant__c where member__r.name = '#{membername}' 
			and challenge__r.challenge_id__c = '#{challenge_id}'")

		if challenge_status.count == 0
			{:success => false, :message => 'Judges cannot be added this challenge at this time.'}	
		elsif current_judge.count > 0
			{:success => false, :message => 'Unable to add you as a judge. You are already a judge for this challenge.'}				
		elsif current_participant.count > 0
			{:success => false, :message => 'Unable to add you as a judge. You are already a participant on this challenge.'}
		elsif total_judges.count == 2
			{:success => false, :message => 'Unable to add you as a judge. There are already a maximum of two judges for this challenge.'}				
		else
			create_in_salesforce(access_token, 'Challenge_Reviewer__c', 
				{'Challenge__c' => Challenge.salesforce_id(access_token, challenge_id), 
				'Member__c' => Member.salesforce_member_id(access_token, membername)})			
			{:success => true, :message => 'Thank you! You are now a judge for this challenge.'}
		end
	  
	end

end