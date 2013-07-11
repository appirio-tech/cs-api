require 'member'
require 'challenge'

class Judging  < Salesforce

  def self.save_scorecard_for_participant(access_token, participant_id, answers, comments, options)

    begin

      # mark the scorecard as rejected
      if options[:delete_scorecard] == 'true'
        update_in_salesforce(access_token, 'Challenge_Participant__c', {'id' => participant_id, 
          'Has_Submission__c' => false, 'Status__c' => 'Submission Rejected'})
        results_hash = {:success => true, :message => 'Scorecard marked as invalid and submission rejected.'}	

      # update the answer for each question
      else

        answers.each do |key, value| 
          results = update_in_salesforce(access_token, 'QwikScore_Question_Answer__c', 
            {'id' => key, 'answer_text__c' => value, 'comments__c' => comments[key]})
        end
        results_hash = {:success => true, :message => 'Scorecard has been saved successfully.'}	

        if options[:scored] == 'true'
          # get the id of the scorecard for this member and judge
          scorecard = query_salesforce(access_token, "select id from QwikScore_Scorecard__c 
            where Challenge_Participant__c = '#{participant_id}' and 
            Reviewer__r.name = '#{options[:judge_membername]}' limit 1")

          set_header_token(access_token) 
          grade_results = get_apex_rest("/gradeScorecard?scorecardId=#{scorecard.first.id}")	
          if grade_results['success'].downcase == 'true'
            results_hash = {:success => true, :message => 'Scorecard successfully submitted.'}	
          else
            results_hash = {:success => false, :message => 'There was an error submitting the scorecard.'}	
          end
        end

      end

    rescue Exception => e	
      results_hash = {:success => false, :message => e.message}
    end
    results_hash

  end

  def self.find_scorecard_by_participant(access_token, participant_id, judge_membername)
    set_header_token(access_token) 
    get_apex_rest("/scorecard/#{participant_id}?reviewer=#{judge_membername}")
  end

  def self.outstanding_scorecards_by_member(access_token, membername)
    set_header_token(access_token) 
    get_apex_rest("/members/#{membername}/outstandingscorecards", 'v1')
  end	

  def self.queue(access_token)
    query_salesforce(access_token, "select id, challenge_id__c, name, status__c, number_of_reviewers__c, 
      end_date__c, review_date__c,
      (select display_name__c from challenge_categories__r),
      (select name__c from challenge_platforms__r),
      (select name__c from challenge_technologies__r) 
      from Challenge__c where community_judging__c = true and status__c IN ('Open for Submissions','Review')
      and number_of_reviewers__c < 3 order by end_date__c")
  end

  def self.add(access_token, challenge_id, membername)
    options = {
      :body => {
          :challenge_id => challenge_id,
          :memberName => membername
      }.to_json
    }
    set_header_token(access_token) 
    results = post_apex_rest('/judging', options)
    {:success => results['success'].to_bool, :message => results['message']}
  end

end