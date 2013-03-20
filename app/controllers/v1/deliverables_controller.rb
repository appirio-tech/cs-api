class V1::DeliverablesController < V1::ApplicationController

  before_filter :restrict_access

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
  #   - JSON containing the following keys: success, message
  # * *Raises* :
  #   - ++ ->
  #   
  def create
    expose Deliverable.create(@oauth_token, params[:membername].strip,
      params[:challenge_id].strip, params[:data])
  end       

  # Updates a deliverable for a participant
  # * *Args*    :
  #   - access_token -> the oauth token to use
  #   - params[:data] -> the JSON to use to create the deliverable, must
  #     contain the id of the deliverable to update
  # * *Returns* :
  #   - JSON containing the following keys: success, message
  # * *Raises* :
  #   - ++ ->
  #   
  def update
    expose Deliverable.update(@oauth_token, params[:data])
  end    

  #
  # This will go away with the new submission process
  #  
  def current_submssions
    expose Deliverable.current_submssions(@oauth_token, params[:membername].strip,
      params[:challenge_id].strip)
  end  

  #
  # This will go away with the new submission process
  #  
  def submission_url_file
    expose Deliverable.create_url_or_file_submission(@oauth_token, params[:membername].strip,
      params[:challenge_id].strip, params)  
  end

  #
  # This will go away with the new submission process
  # 
  def delete_submission_url_file
    expose Deliverable.delete_url_or_file_submission(@oauth_token, params[:submission_id])  
  end

  #
  # This will go away with the new submission process
  # 
  def find
    expose Deliverable.find(@oauth_token, params[:submission_id])  
  end  

end