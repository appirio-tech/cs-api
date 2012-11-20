class Stats < Salesforce

  #
  # Returns the public stats
  # * *Args*    :
  #   - access_token -> the oauth token to use
  #   - options -> a hash with the period to select, category and limit
  # * *Returns* :
  #   - JSON containing a collection of members with their leaderboard scores
  # * *Raises* :
  #   - ++ ->
  #   
	def self.public(access_token)
		set_header_token(access_token)   
    get_apex_rest("/stats")
	end

end