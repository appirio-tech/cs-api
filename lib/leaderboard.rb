class Leaderboard < Salesforce

  #
  # Returns the public leaderboard results
  # * *Args*    :
  #   - access_token -> the oauth token to use
  #   - options -> a hash with the period to select, category and limit
  # * *Returns* :
  #   - JSON containing a collection of members with their leaderboard scores
  # * *Raises* :
  #   - ++ ->
  #   
  # DEPRECATED -- NO LONGER NEEDED
	def self.public(access_token, options = {:period => nil, :category => nil, :limit => nil})

		set_header_token(access_token)   
    request_url  = ENV['SFDC_APEXREST_URL'] + '/leaderboard?1=1'
    request_url += ("&period=#{esc options[:period]}") unless options[:period].nil?
    request_url += ("&category=#{esc options[:category]}") unless options[:category].nil?
    request_url += ("&limit=#{options[:limit]}") unless options[:limit].nil?
    leaderboard =  get(request_url)
    #sort by total_money
    leaderboard.sort_by! { |key| key['total_money'].to_i }
    # reverse the order so the largest is at the top
    leaderboard.reverse!
    # add a rank to each one
    rank = 1
    leaderboard.each do |record| 
      record.merge!({'rank' => rank})
      rank = rank + 1
    end

    # return the leaderboard
    Forcifier::JsonMassager.deforce_json(leaderboard)

	end

  #
  # Returns the public leaderboard results
  # * *Args*    :
  #   - access_token -> the oauth token to use
  #   - options -> a hash with the period to select, category and limit
  # * *Returns* :
  #   - JSON containing a collection of members with their leaderboard scores
  # * *Raises* :
  #   - ++ ->
  #   
  def self.public_all(access_token, options = {:limit => nil})

    set_header_token(access_token)   
    request_url  = ENV['SFDC_APEXREST_URL'] + '/leaderboard_all?1=1'
    request_url += ("&period=#{esc options[:period]}") unless options[:period].nil?
    request_url += ("&category=#{esc options[:category]}") unless options[:category].nil?
    request_url += ("&limit=#{options[:limit]}") unless options[:limit].nil?
    leaderboard =  get(request_url)
    #sort by total_money
    leaderboard['this_year'] = sort_leaderbaord(leaderboard['this_year'])
    leaderboard['this_month'] = sort_leaderbaord(leaderboard['this_month'])
    leaderboard['all_time'] = sort_leaderbaord(leaderboard['all_time'])

    # return the leaderboard
    Forcifier::JsonMassager.deforce_json(leaderboard)

  end  

  #
  # Returns the referral leaderbaord (FOR APPIRIO ONLY!!)
  # * *Args*    :
  #   - access_token -> the oauth token to use
  #   - options -> a hash with the period to select, category and limit
  # * *Returns* :
  #   - JSON containing a collection of members with their leaderboard scores
  # * *Raises* :
  #   - ++ ->
  #   
  def self.referral(access_token)
    leaderboard = query_salesforce(access_token, "select count(id)total, referred_by_member__r.name, 
      referred_by_member__r.profile_pic__c, referred_by_member__r.country__c from Referral__c 
      where converted__c = true and referred_by_member__r.account__r.name = 'appirio' 
      group by referred_by_member__r.name, referred_by_member__r.profile_pic__c, referred_by_member__r.country__c")
    
    leaderboard.sort_by! { |key| key['total'].to_i }
    # reverse the order so the largest is at the top
    leaderboard.reverse!
    # add a rank to each one
    rank = 1
    leaderboard.each do |record| 
      record.merge!({'rank' => rank})
      rank = rank + 1
    end    

    leaderboard
  end

  private

    def self.sort_leaderbaord(leaderboard)

      leaderboard.sort_by! { |key| key['total_money'].to_i }
      # reverse the order so the largest is at the top
      leaderboard.reverse!
      # add a rank to each one
      rank = 1
      leaderboard.each do |record| 
        record.merge!({'rank' => rank})
        rank = rank + 1
      end 
      return leaderboard   

    end  

end