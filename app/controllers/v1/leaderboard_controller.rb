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
  #   - period -> the period (nil (all), month, year)
  #   - category -> the category to return
  #   - limit -> the limit of records to return -- may not 
  #   work correctly as expected.
  # * *Returns* :
  #   - JSON an array leaderboard objects
  # * *Raises* :
  #   - ++ ->
  #  
	def public
		expose Leaderboard.public(@oauth_token, :period => params[:period] || nil, 
      :category => params[:category] || nil, :limit => params[:limit] || 1000)
	end

end