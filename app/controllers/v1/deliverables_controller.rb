class V1::DeliverablesController < V1::ApplicationController

  # before_filter :restrict_access

	# inherit from actual member model. Submissions in this controller uses the
	# subclass so we can overrid any functionality for this version of api.
	class Deliverable < ::Deliverable

	end	

  #
  # Returns all deliverables for a participant
  # * *Args*    :
  #   - access_token -> the oauth token to use
  #   - membername -> the participant's cloudspokes member name
  #   - challenge_id -> the participant's challenge id
  # * *Returns* :
  #   - JSON collection of deliverables objects
  # * *Raises* :
  #   - ++ ->
  #  
  def all
    expose Deliverable.all(@oauth_token, params[:membername].strip,
      params[:challenge_id].strip)
  end    

  # Creates a new deliverable for a participant
  # * *Args*    :
  #   - access_token -> the oauth token to use
  #   - membername -> the participant's cloudspokes member name
  #   - challenge_id -> the participant's challenge id
  #   - params[:data] -> the JSON to use to create the deliverable
  # * *Returns* :
  #   - a hash containing the following keys: success, errors
  # * *Raises* :
  #   - ++ ->
  #   
  def create
    expose Deliverable.create(@oauth_token, params[:membername].strip,
      params[:challenge_id].strip, params[:data])
  end       

end