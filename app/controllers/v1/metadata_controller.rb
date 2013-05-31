class V1::MetadataController < V1::ApplicationController

  # inherit from lib/stats. Objects in this controller uses the
  # subclass so we can overrid any functionality for this version of api.
  class Metadata < ::Metadata

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
  def categories
    expose Metadata.categories(@oauth_token)
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
  def technologies
    expose Metadata.technologies(@oauth_token)
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
  def platforms
    expose Metadata.platforms(@oauth_token)
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
  def stats
    expose Metadata.stats(@oauth_token)
  end  

  #
  # Returns a hash of picklist fields with values.
  # * *Args*    :
  # * *Returns* :
  #   - JSON containing name value pairs for stats
  # * *Raises* :
  #   - ++ ->
  #  
  def participant
    expose Metadata.participant(@oauth_token)
  end    

end