class V1::SquirrelforceController < V1::ApplicationController

	# before_filter :restrict_access

  # may not need the admin_oauth_token but right now only admins have access to Deliverable__c
  def unleash_squirrel
    expose Squirrelforce.unleash_squirrel(admin_oauth_token, params[:submission_deliverable_id])
  end	

  def reserve_server
    expose Squirrelforce.reserve_server(admin_oauth_token, params[:membername])
  end

  def release_server
    expose Squirrelforce.release_server(admin_oauth_token, params[:reservation_id])
  end

  def papertrail_system
    expose Squirrelforce.papertrail_system(params[:participant_id])
  end

end
