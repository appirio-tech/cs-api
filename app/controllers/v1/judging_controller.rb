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

end
