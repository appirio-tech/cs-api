class Metadata< Salesforce

  def self.platforms(access_token) 
    query_salesforce(access_token, "select name from platform__c 
      where active__c = true order by name").map { |t| t.name }
  end

  def self.categories(access_token) 
    %w(Code Design Eval First2Finish Rookie Sweepstakes TopCoder)
  end

  def self.technologies(access_token) 
    query_salesforce(access_token, "select name from technology__c 
      where active__c = true order by name").map { |t| t.name }
  end  

  def self.participant(access_token) 
    languages = picklist_values(access_token, 'Challenge_Participant__c', 'Languages__c').map { |v| v.label }
    technologies = picklist_values(access_token, 'Challenge_Participant__c', 'Technologies__c').map { |v| v.label }
    platforms = picklist_values(access_token, 'Challenge_Participant__c', 'PaaS__c').map { |v| v.label }
    {:languages => languages, :technologies => technologies, :platforms => platforms}
  end    

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
  def self.stats(access_token)
    set_header_token(access_token)
    # get the members stats from the soap service or cache
    public_member_stats = Rails.cache.fetch('public_member_stats', expires_in: 30.minutes) do
      puts "[INFO][Stats] Fetching member count from SOAP service as cache expired."
      client = Savon.client(ENV['STATS_WSDL_URL'])
      response = client.request(:stat, :platform_stats) do
        soap.namespaces["xmlns:stat"] = "http://soap.sforce.com/schemas/class/StatsWS"
        soap.header = { 'stat:SessionHeader' => { 'stat:sessionId' => access_token }}
      end
      response.to_array(:platform_stats_response, :result).first
    end
    # add in the topcoder open challenge count
    #public_member_stats[:challenges_open] = public_member_stats[:challenges_open].to_i + Topcoder.challenges_open.count if ENV['TOPCODER_INCLUDE_DATA'] == 'true' 
    public_member_stats
  end  

end