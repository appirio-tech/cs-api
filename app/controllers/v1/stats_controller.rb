class V1::StatsController < V1::ApplicationController

  require 'stats'

  # inherit from lib/stats. Objects in this controller uses the
  # subclass so we can overrid any functionality for this version of api.
  class Stats < ::Stats

  end     

  #
  # Returns the public stats for the platform. Calls the SOAP web service
  # to get the current member count and caches that. Calls the REST web
  # service each time to ensure challenges, money, etc are correct for
  # each member.
  # * *Args*    :
  # * *Returns* :
  #   - JSON containing name value pairs for stats
  # * *Raises* :
  #   - ++ ->
  #  
  def public
    expose Stats.public(@oauth_token)
  end  

end