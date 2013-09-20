class V1::CommunitiesController < V1::ApplicationController

  #before_filter :restrict_access, :only => [:add_member]  

  def all
    expose Community.all(@oauth_token)
  end	

  def find
    community =  Community.find(@oauth_token, params[:community_id])
    error! :not_found unless community
    expose community
  end

  def add_member
    expose Community.add_member(admin_oauth_token, params)
  end  

end
