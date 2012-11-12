class V1::ParticipantsController < V1::ApplicationController

	before_filter :restrict_access

	# inherit from actual participant model. Participants in this controller uses the
	# subclass so we can overrid any functionality for this version of api.
	class Participant < ::Participant

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
  # Creates a new challenge_participant records
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
  # Updaes an existing challenge_participant record
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