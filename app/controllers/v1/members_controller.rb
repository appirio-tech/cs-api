class V1::MembersController < V1::ApplicationController

	require 'forcifier'

	# inherit from actual member model. Members in this controller uses the
	# subclass so we can overrid any functionality for this version of api.
	class Member < ::Member

	end	

  #
  # Returns all challenges.
  # * *Args*    :
  #   - access_token -> the oauth token to use
  #   - fields (optional) -> the fields to return in the results. Defaults
	#	  to MEMBER_SEARCH_FIELDS.
  #   - order_by (optional) -> the fields to order the results by. Defaults
	#	  to total_wins__c.	
  # * *Returns* :
  #   - JSON an array of challenges 
  # * *Raises* :
  #   - ++ ->
  #  
	def index
		expose Member.all(@oauth_token, index_fields, index_order_by)
	end

  #
  # Searches for a member by keywords search.
  # * *Args*    :
  #   - access_token -> the oauth token to use
  #   - fields (optional) -> the fields to return in the results. Defaults
	#	  to MEMBER_SEARCH_FIELDS.
  #   - keyword -> the keyword used in the search
  # * *Returns* :
  #   - JSON an array of members 
  # * *Raises* :
  #   - ++ ->
  #  
	def search
		expose Member.search(@oauth_token, search_fields, params[:keyword])
	end

	def show
		member = Member.find_by_username(@oauth_token, params[:membername], PUBLIC_MEMBER_FIELDS).first
		challenges = Member.challenges(@oauth_token, params[:membername])
		recommendations = Member.recommendations(@oauth_token, params[:membername], DEFAULT_RECOMMENDATION_FIELDS)
		h = { 'member' => member, 'challenges' => challenges, 'recommendations' => recommendations}
		error! :not_found unless member
		expose h
	end

  #
  # Returns the recommendations for a member
  # * *Args*    :
  #   - access_token -> the oauth token to use
  #   - membername -> the member to return recommendations for
  #   - fields (optional) -> the fields to return in the results. Defaults
	#	  to DEFAULT_RECOMMENDATION_FIELDS.
  # * *Returns* :
  #   - JSON an array of recommendations 
  # * *Raises* :
  #   - ++ ->
  #  
	def recommendations
		expose Member.recommendations(@oauth_token, params[:membername], recommendations_fields)
	end

	def recommendation_create
		expose Member.recommendation_create(@oauth_token, params[:membername], 
			params[:recommendation_from_username], params[:recommendation_text])
	end

	protected

		def index_fields
			params[:fields] ? Forcifier.enforce_fields(params[:fields]) : MEMBER_SEARCH_FIELDS
		end

		def index_order_by
			params[:order_by] ||= 'total_wins__c'
		end

		def search_fields
			params[:fields] ? Forcifier.enforce_fields(params[:fields]) : MEMBER_SEARCH_FIELDS
		end

		def recommendations_fields
			params[:fields] ? Forcifier.enforce_fields(params[:fields]) : DEFAULT_RECOMMENDATION_FIELDS			
		end		

end