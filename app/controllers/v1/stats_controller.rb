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
    sessionId = @oauth_token
    member_stats = Rails.cache.fetch('member_stats', expires_in: 15.minute) do
      puts "[INFO][Stats] Fetching member count from SOAP service as cache expired."
      client = Savon.client(ENV['STATS_WSDL_URL'])
      response = client.request(:stat, :platform_stats) do
        soap.namespaces["xmlns:stat"] = "http://soap.sforce.com/schemas/class/StatsWS"
        soap.header = { 'stat:SessionHeader' => { 'stat:sessionId' => sessionId }}
      end
      response.to_array(:platform_stats_response, :result).first
    end
    platform_stats = Stats.public(@oauth_token)
    platform_stats['members'] = member_stats[:members]
    expose platform_stats
  end  

end