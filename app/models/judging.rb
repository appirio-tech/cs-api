require 'member'
require 'challenge'

class Judging  < Salesforce

	def self.outstanding_scorecards_by_member(access_token, membername)
		query_salesforce(access_token, "select id, challenge_participant__c, challenge_participant__r.challenge__r.name, 
	    challenge_participant__r.member__r.name, challenge_participant__r.member__r.profile_pic__c, 
	    challenge_participant__r.submitted_date__c,
	    challenge_participant__r.score__c, total_raw_score__c, challenge_participant__r.challenge__r.challenge_id__c 
	    from qwikscore_scorecard__c 
	    where reviewer__r.name = '"+membername+"' and scored__c = false 
	    and challenge_participant__r.has_submission__c = true
	    order by challenge_participant__r.challenge__r.end_date__c, challenge_participant__r.challenge__r.name, 
	    Total_Raw_Score__c desc, challenge_participant__r.submitted_date__c")
	end	

	def self.queue(access_token)
		query_salesforce(access_token, "select id, challenge_id__c, name, status__c, number_of_reviewers__c, 
			end_date__c, review_date__c,
			(select display_name__c from challenge_categories__r),
			(select name__c from challenge_platforms__r),
			(select name__c from challenge_technologies__r) 
			from Challenge__c where community_judging__c = true and status__c IN ('Created','Submission','Review')
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
			{:success => false, :message => 'Judges cannot be added at this time.'}	
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
  rescue Exception => e
    puts "[FATAL][Judging] Error adding judge: #{e.message}" 
    {:success => false, :message => e.message} 
	end

end