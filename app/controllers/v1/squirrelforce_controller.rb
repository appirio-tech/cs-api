class V1::SquirrelforceController < V1::ApplicationController

	# before_filter :restrict_access

  def unleash_squirrel
    expose Squirrelforce.unleash_squirrel
  end	

  def reserve_server
    expose Squirrelforce.reserve_server(admin_oauth_token, params[:membername])
  end

  def release_server
    expose Squirrelforce.release_server(admin_oauth_token, params[:reservation_id])
  end

end
