class V1::CategoriesController < V1::ApplicationController

	# inherit from actual member model. Categories in this controller uses the
	# subclass so we can overrid any functionality for this version of api.
	class Category < ::Category

	end	

  #
  # Returns all categories
  # * *Args*    :
  #   - access_token -> the oauth token to use
  # * *Returns* :
  #   - A collection of Category objects
  # * *Raises* :
  #   - ++ ->
  #  
	def all
		expose Category.all(@oauth_token)
	end		

end