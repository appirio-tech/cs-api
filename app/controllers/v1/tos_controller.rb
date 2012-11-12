class V1::TosController < V1::ApplicationController

	# inherit from actual member model. Categories in this controller uses the
	# subclass so we can overrid any functionality for this version of api.
	class Tos < ::Tos

	end	

  #
  # Returns a specific TOS by ID
  # * *Args*    :
  #   - access_token -> the oauth token to use
  #   - id -> the salesforce id of the tos to return
  # * *Returns* :
  #   - A Terms_of_Service__c object
  # * *Raises* :
  #   - ++ ->
  #  
	def find
		expose Tos.find(@oauth_token, params[:id])
	end		

end