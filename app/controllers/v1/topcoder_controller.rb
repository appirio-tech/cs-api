class V1::TopcoderController < V1::ApplicationController
  jsonp

  #before_filter :restrict_access

  def find_member
    member = Topcoder.find_by_membername(@oauth_token, params[:membername]).first
    error! :not_found unless member
    expose member
  end  


end