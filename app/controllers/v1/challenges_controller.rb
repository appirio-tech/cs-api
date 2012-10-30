class V1::ChallengesController < V1::ApplicationController

	# inherit from actual member model. Members in this controller uses the
	# subclass so we can overrid any functionality for this version of api.
	class Challenge < ::Challenge

	end	

end