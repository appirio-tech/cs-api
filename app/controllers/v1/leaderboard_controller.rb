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
  # DEPRECATED - NO LONGER NEEDED
	def public
		expose Leaderboard.public(@oauth_token, :period => params[:period] || nil, 
      :category => params[:category] || nil, :limit => params[:limit] || 1000)
	end

  #
  # Returns the current public leaderbaord in a group with all 3 types.
  # * *Args*    :
  #   - access_token -> ALWAYS USES THE ADMIN TOKEN so it will return payments
  #   for private challenges
  #   - limit -> the limit of records to return -- may not 
  #   work correctly as expected.
  # * *Returns* :
  #   - JSON an array leaderboard objects
  # * *Raises* :
  #   - ++ ->
  #  
  def public_all
    expose Leaderboard.public_all(admin_oauth_token, :limit => params[:limit] || 1000)
  end  

  #
  # Returns the referral leaderboard.
  # * *Args*    :
  #   - access_token -> the oauth token to use
  #   work correctly as expected.
  # * *Returns* :
  #   - JSON an array leaderboard objects
  # * *Raises* :
  #   - ++ ->
  #  
  def referral
    expose Leaderboard.referral(@oauth_token)
  end  

end