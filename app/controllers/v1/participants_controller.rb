class V1::ParticipantsController < V1::ApplicationController

	before_filter :restrict_access

	# inherit from actual participant model. Participants in this controller uses the
	# subclass so we can overrid any functionality for this version of api.
	class Participant < ::Participant

	end	

  #
  # Returns a specific participant
  # * *Args*    :
  #   - access_token -> the oauth token to use
  #   - participant_id -> the id of the participant to fetch
  # * *Returns* :
  #   - JSON a challenge object containing a terms_of_service__r
  #   and collection of challenge_categories__r and challenge_prizes__r
  # * *Raises* :
  #   - ++ -> 404 if not found
  #   
  def find
    participant = Participant.find(@oauth_token, params[:participant_id].strip)
    error! :not_found unless participant
    expose participant
  end       

  #
  # Returns the status for a member for a challenge
  # * *Args*    :
  #   - access_token -> the oauth token to use
  #   - membername -> the participant's cloudspokes member name
  #   - challenge_id -> the participant's challenge id
  # * *Returns* :
  #   - JSON containing the following keys: success, message. Returns
  #   nil if record does not exist.
  # * *Raises* :
  #   - ++ ->
  #  
	def current_status
		expose Participant.status(@oauth_token, params[:membername].strip,
			params[:challenge_id].strip)
	end			

  #
  # Creates a new challenge_participant record
  # if the member/challenge combination doesn't
  # exixt (this is handled in the Apex REST)
  # * *Args*    :
  #   - access_token -> the oauth token to use
  #   - membername -> the participant's cloudspokes member name
  #   - challenge_id -> the participant's challenge id
  #   - fields -> the field to populate for the creation (enforces them)
  # * *Returns* :
  #   - JSON containing the following keys: success, message
  # * *Raises* :
  #   - ++ ->
  #  
	def create
		expose Participant.create(@oauth_token, params[:membername].strip,
			params[:challenge_id].strip, params[:fields])
	end			

  #
  # Updates an existing challenge_participant record
  # * *Args*    :
  #   - access_token -> the oauth token to use
  #   - membername -> the participant's cloudspokes member name
  #   - challenge_id -> the participant's challenge id
  #   - fields -> the field to populate for the update (enforces them)
  # * *Returns* :
  #   - JSON containing the following keys: success, message
  # * *Raises* :
  #   - ++ ->
  #  
	def update
		expose Participant.update(@oauth_token, params[:membername].strip,
			params[:challenge_id].strip, params[:fields])
	end				

end