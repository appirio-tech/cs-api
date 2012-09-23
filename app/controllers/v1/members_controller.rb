class V1::MembersController < V1::ApplicationController

	# inherit from actual product model. challenges in this controller uses the
	# subclass so we can overrid any functionality for this version of api.
	class Member < ::Member

	end	

	def index
		expose Member.all(@oauth_token, MEMBER_SEARCH_FIELDS, 'total_wins__c')
	end

	def search
		expose Member.search(@oauth_token, MEMBER_SEARCH_FIELDS, params[:membername])
	end

	def show
		member = Member.find_by_username(@oauth_token, params[:id], PUBLIC_MEMBER_FIELDS).first
		challenges = Member.challenges(@oauth_token, params[:id])
		recommendations = Member.recommendations(@oauth_token, params[:id],DEFAULT_RECOMMENDATION_FIELDS)
		h = { 'member' => member, 'challenges' => challenges, 'recommendations' => recommendations}
		error! :not_found unless member
		expose h
	end

end