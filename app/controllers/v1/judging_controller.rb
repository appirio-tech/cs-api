class V1::JudgingController < V1::ApplicationController

	#before_filter :restrict_access

  def queue
    expose Judging.queue(@oauth_token)
  end	

  def add
    expose Judging.add(@oauth_token, params[:challenge_id], params[:membername])
  end   

end
