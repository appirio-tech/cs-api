class V1::LeaderboardController < V1::ApplicationController

  require 'leaderboard'

  # inherit from lib/leaderboard. Objects in this controller uses the
  # subclass so we can overrid any functionality for this version of api.
  class Leaderboard < ::Leaderboard

  end   

  #
  # Returns the current public leaderbaord.
  # * *Args*    :
  #   - access_token -> the oauth token to use
  # * *Returns* :
  #   - JSON an array leaderboard objects
  # * *Raises* :
  #   - ++ ->
  #  
	def index
		expose Leaderboard.public(@oauth_token)
	end

end