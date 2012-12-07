class V1::CommunitiesController < V1::ApplicationController

  before_filter :restrict_access, :only => [:add_member]  

  def all
    expose Community.all(@oauth_token)
  end	

  def find
    expose Community.find(@oauth_token, params[:community_id])
  end

  def add_member
    expose Community.add_member(admin_oauth_token, params)
  end  

end
