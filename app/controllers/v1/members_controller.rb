class V1::MembersController < V1::ApplicationController

	require 'forcifier'

	before_filter :restrict_access, :only => [:payments, :recommendation_create]

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
		expose Member.search(@oauth_token, params[:keyword], search_fields)
	end

  #
  # Returns all data for the specified user. This includes their member info,
  # challenges they've been involved in and their recommendations
  # * *Args*    :
  #   - access_token -> the oauth token to use
  #   - membername -> the member to return all info for
  # * *Returns* :
  #   - a hash containing the following keys: member, challenges, recommendations
  # * *Raises* :
  #   - ++ ->
  #  
	def find_by_membername
		member = Member.find_by_membername(@oauth_token, params[:membername], PUBLIC_MEMBER_FIELDS).first
		challenges = Member.challenges(@oauth_token, params[:membername])
		recommendations = Member.recommendations(@oauth_token, params[:membername], DEFAULT_RECOMMENDATION_FIELDS)
		h = { 'member' => member, 'challenges' => challenges, 'recommendations' => recommendations}
		error! :not_found unless member
		expose h
	end

  #
  # Returns all of the challenges that a member has been involved in
  # * *Args*    :
  #   - access_token -> the oauth token to use
  #   - membername -> the member to return payments for
  # * *Returns* :
  #   - JSON an array of challenges 
  # * *Raises* :
  #   - ++ ->
  # 
  def challenges
    expose Member.challenges(@oauth_token, params[:membername])
  end   

  #
  # Returns all payments for a member
  # * *Args*    :
  #   - access_token -> the oauth token to use
  #   - membername -> the member to return payments for
  #   - fields (optional) -> the fields to return in the results. Defaults
	#	  to DEFAULT_PAYMENT_FIELDS.
  #   - order_by (optional) -> the fields to order the results by. Defaults
	#	  to id.		
  # * *Returns* :
  #   - JSON an array of payments 
  # * *Raises* :
  #   - ++ ->
  # 
	def payments
		expose Member.payments(@oauth_token, params[:membername], payments_fields, payments_order_by)
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

  #
  # Creates a recommendation for the specified member
  # * *Args*    :
  #   - access_token -> the oauth token to use
  #   - membername -> the member to create the recommendations for
  #   - recommendation_from_username -> the member the recommendation is from
  #   - recommendation_text -> the text of the recommendation
  # * *Returns* :
	#   - JSON containing the following keys: success, message
  # * *Raises* :
  #   - ++ ->
  #  
	def recommendation_create
		expose Member.recommendation_create(@oauth_token, params[:membername], 
			params[:recommendation_from_username], params[:recommendation_text])
	end

	protected

		def index_fields
			params[:fields] ? Forcifier.enforce_fields(params[:fields]) : MEMBER_SEARCH_FIELDS
		end

		def index_order_by
			params[:order_by] ? Forcifier.enforce_fields(params[:order_by]) : 'total_wins__c'
		end

		def search_fields
			params[:fields] ? Forcifier.enforce_fields(params[:fields]) : MEMBER_SEARCH_FIELDS
		end

		def payments_fields
			params[:fields] ? Forcifier.enforce_fields(params[:fields]) : DEFAULT_PAYMENT_FIELDS
		end		

		def payments_order_by
			params[:order_by] ? Forcifier.enforce_fields(params[:order_by]) : 'id'
		end				

		def recommendations_fields
			params[:fields] ? Forcifier.enforce_fields(params[:fields]) : DEFAULT_RECOMMENDATION_FIELDS			
		end		

end