class V1::ChallengesController < V1::ApplicationController

	before_filter :restrict_access, :only => [:create, :update]

	# inherit from actual member model. Challenges in this controller uses the
	# subclass so we can overrid any functionality for this version of api.
	class Challenge < ::Challenge

	end	

	def create
		expose Challenge.create(@oauth_token, params[:data])
	end			

	def update
		expose Challenge.update(@oauth_token, params[:challenge_id].strip,
			params[:data])
	end			

	def find
		expose Challenge.find(@oauth_token, params[:challenge_id].strip)
	end			

	def participants
		expose Challenge.participants(@oauth_token, params[:challenge_id].strip)
	end				

	def comments
		expose Challenge.comments(@oauth_token, params[:challenge_id].strip)
	end				

	def open
		expose Challenge.all(@oauth_token, 'true', 
			params[:category] ||= nil, 
			enforce_order_by_params(params[:order_by], 'name'))
	end	

	def closed
		expose Challenge.all(@oauth_token, 'false', 
			params[:category] ||= nil, 
			enforce_order_by_params(params[:order_by], 'name'))
	end		

	def recent
		expose Challenge.recent(@oauth_token)
	end		

end