class V1::PlatformsController < V1::ApplicationController

  # inherit from actual member model. Platform in this controller uses the
  # subclass so we can overrid any functionality for this version of api.
  class Platform < ::Platform

  end 

  #
  # Returns all platforms
  # * *Args*    :
  #   - access_token -> the oauth token to use
  # * *Returns* :
  #   - A collection of Platform objects
  # * *Raises* :
  #   - ++ ->
  #  
  def all
    expose Platform.all(@oauth_token)
  end   

end