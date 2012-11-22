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
    # get the members stats from the soap service or cache
    public_member_stats = Rails.cache.fetch('public_member_stats', expires_in: 15.minute) do
      puts "[INFO][Stats] Fetching member count from SOAP service as cache expired."
      client = Savon.client(ENV['STATS_WSDL_URL'])
      response = client.request(:stat, :platform_stats) do
        soap.namespaces["xmlns:stat"] = "http://soap.sforce.com/schemas/class/StatsWS"
        soap.header = { 'stat:SessionHeader' => { 'stat:sessionId' => access_token }}
      end
      response.to_array(:platform_stats_response, :result).first
    end
    # get the stats from the rest service
    platform_stats = get_apex_rest("/stats")
    # add in the number of members from the soap service
    platform_stats['members'] = public_member_stats[:members]
    platform_stats
	end

end