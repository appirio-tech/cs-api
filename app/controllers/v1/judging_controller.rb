class V1::JudgingController < V1::ApplicationController

  before_filter :restrict_access

  def queue
    expose Judging.queue(@oauth_token)
  end	

  def add
    expose Judging.add(@oauth_token, params[:challenge_id], params[:membername])
  end   

  def outstanding_scorecards_by_member
    expose Judging.outstanding_scorecards_by_member(@oauth_token, params[:membername])
  end

  def find_scorecard_by_participant
    expose Judging.find_scorecard_by_participant(@oauth_token, params[:id], 
      params[:judge_membername])
  end      

  def save_scorecard_for_participant
    expose Judging.save_scorecard_for_participant(@oauth_token, params[:id], 
      params[:answers], params[:comments], params[:options])
  end

end
