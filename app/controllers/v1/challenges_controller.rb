class V1::ChallengesController < V1::ApplicationController
  jsonp

	before_filter :restrict_access, :only => [:create, :update, :survey, :submission_deliverables]

	# inherit from actual challenge model. Challenges in this controller uses the
	# subclass so we can overrid any functionality for this version of api.
	class Challenge < ::Challenge

	end	

  #
  # Returns a specific challange, categories, prizes and terms
  # * *Args*    :
  #   - access_token -> the oauth token to use
  #   - challenge_id -> the id of the challenge to fetch
  # * *Returns* :
  #   - JSON a challenge object containing a terms_of_service__r
  #   and collection of challenge_categories__r and challenge_prizes__r
  # * *Raises* :
  #   - ++ -> 404 if not found or hidden
  #  	
	def find
		challenge = Challenge.find(@oauth_token, params[:challenge_id].strip, 
      params[:admin] ||= false)
		error! :not_found unless challenge
    error! :not_found if challenge['status'].downcase == 'hidden'
		expose challenge
	end					

  #
  # Returns all currently open or closed challenges
  # * *Args*    :
  #   - access_token -> the oauth token to use
  #   - open -> 'true'/'false'    
  #   - category (optional) -> the category of challenges to return. Defaults
  #   to nil. 
  #   - order_by (optional) -> the field to order the results by. Defaults
  #   to name.    
  # * *Returns* :
  #   - JSON a collection of challenge objects with challenge_categories__r 
  # * *Raises* :
  #   - ++ ->
  #   
  def all
    expose Challenge.all(@oauth_token, params[:open], 
      params[:technology] ||= nil, 
      params[:platform] ||= nil, 
      params[:category] ||= nil, 
      enforce_order_by_params(params[:order_by], 'end_date__c'),
      params[:limit] ||= 25,
      params[:offset] ||= 0)
  end   

  #
  # Returns all recently closed challenges with winners selected
  # * *Args*    :
  #   - access_token -> the oauth token to use
  #   - limit -> the number of records to return
  #   - offset -> specifies the starting row offset into the result set 
  # returned by your query  	
  # * *Returns* :
  #   - JSON a collection of challenge objects with 
  #   challenge_categories__r and challenge_participants__r
  # * *Raises* :
  #   - ++ ->
  #  	
	def recent
		expose Challenge.recent(@oauth_token,
      params[:limit] ||= 25,
      params[:offset] ||= 0)
	end		

  #
  # Creates a new challenge
  # * *Args*    :
  #   - access_token -> the oauth token to use	
  #   - params[:data] -> the JSON to use to create the
  #   challenge. See spec/data/create_challenge.json for example.
  # * *Returns* :
  #   - a hash containing the following keys: success, challenge_id, errors
  # * *Raises* :
  #   - ++ ->
  #  	
	def create
		expose Challenge.create(@oauth_token, params[:data])
	end			

  #
  # Updates an existing challenge
  # * *Args*    :
  #   - access_token -> the oauth token to use	
  #   - params[:data] -> the JSON to use to update the
  #   challenge. See spec/data/update_challenge.json for example.
  # * *Returns* :
  #   - a hash containing the following keys: success, challenge_id, errors
  # * *Raises* :
  #   - ++ ->
  #  	
	def update
		expose Challenge.update(@oauth_token, params[:challenge_id].strip,
			params[:data])
	end	

  #
  # Performs simple, keyword search against open challenges
  # * *Args*    :
  #   - access_token -> the oauth token to use
  #   - keyword -> the keyword used in the search
  # * *Returns* :
  #   - JSON an array of challenges 
  # * *Raises* :
  #   - ++ ->
  #  
  def search
    expose Challenge.search(@oauth_token, params[:keyword])
  end  

  #
  # Returns a collection of participants for a challenge
  # * *Args*    :
  #   - access_token -> the oauth token to use
  #   - challenge_id -> the id of the challenge to fetch participants for  	
  # * *Returns* :
  #   - JSON a collection of participants with member__r data
  # * *Raises* :
  #   - ++ ->
  #  	
	def participants
		expose Challenge.participants(@oauth_token, params[:challenge_id].strip)
	end			

  #
  # Returns a collection of scorecards for a challenge
  # * *Args*    :
  #   - access_token -> the oauth token to use
  #   - challenge_id -> the id of the challenge to fetch participants for   
  # * *Returns* :
  #   - JSON a collection of scorecards records
  # * *Raises* :
  #   - ++ ->
  #   
  def scorecards
    expose Challenge.scorecards(@oauth_token, params[:challenge_id].strip)
  end      	

  #
  # Returns a collection of submissions for a challenge
  # * *Args*    :
  #   - access_token -> the oauth token to use
  #   - challenge_id -> the id of the challenge to fetch participants for   
  # * *Returns* :
  #   - JSON a collection of submissions records
  # * *Raises* :
  #   - ++ ->
  #   
  def submission_deliverables
    expose Challenge.submission_deliverables(@oauth_token, params[:challenge_id].strip)
  end       

  #
  # Returns a collection of comments for a challenge
  # * *Args*    :
  #   - access_token -> the oauth token to use
  #   - challenge_id -> the id of the challenge to fetch participants for  	
  # * *Returns* :
  #   - JSON a collection of comments objects with member__r data and
  #   challenge_comments__r for comment replies
  # * *Raises* :
  #   - ++ ->
  #  
	def comments
		expose Challenge.comments(@oauth_token, params[:challenge_id].strip)
	end		

  # DO NOT USE THIS WITH THE CURRENT SITE
  # Creates a new discussion board comment for the challenge
  # * *Args*    :
  #   - access_token -> the oauth token to use   
  #   - params[:data] -> the JSON to use to create the
  #   comment. 
  # * *Returns* :
  #   - a hash containing the following keys: success, errors
  # * *Raises* :
  #   - ++ ->
  #   
  def comment
    expose Challenge.comment(@oauth_token, params[:data])
  end     

  #
  # Creates a new survey for a challenge
  # * *Args*    :
  #   - access_token -> the oauth token to use 
  #   - challenge_id -> the id of the challenge to create the survey for
  #   - params[:data] -> the hash containing the survey responses
  # * *Returns* :
  #   - a hash containing the following keys: success, message
  # * *Raises* :
  #   - ++ ->
  #   
  def survey
    expose Survey.create(@oauth_token, params[:challenge_id].strip, 
      params[:data])
  end   

  #
  # Returns the scorecard for a challenge
  # * *Args*    :
  #   - access_token -> the oauth token to use 
  #   - challenge_id -> the id of the challenge to fetch the scorecard fro
  # * *Returns* :
  #   - a JSON collection of scorecard questions
  # * *Raises* :
  #   - ++ ->
  #   
  def scorecard
    expose Challenge.scorecard(@oauth_token, params[:challenge_id].strip)
  end   

end