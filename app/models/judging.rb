require 'member'
require 'challenge'

class Judging  < Salesforce

  def self.save_scorecard_for_participant(access_token, participant_id, answers, comments, options)
    set_header_token(access_token) 
    results = put_apex_rest("/scorecard", {:answers => answers.to_param, 
      :comments => comments.to_param, :options => options.to_param, :participant_id => participant_id})   
    {:success => results['success'].downcase.to_bool, :message => results['message']}
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