class V1::TechnologiesController < V1::ApplicationController

	# inherit from actual member model. Technologies in this controller uses the
	# subclass so we can overrid any functionality for this version of api.
	class Technology < ::Technology

	end	

  #
  # Returns all technologies
  # * *Args*    :
  #   - access_token -> the oauth token to use
  # * *Returns* :
  #   - A collection of Technology objects
  # * *Raises* :
  #   - ++ ->
  #  
	def all
		expose Technology.all(@oauth_token)
	end		

end