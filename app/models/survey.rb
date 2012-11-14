class Survey < Salesforce

  #
  # Creates a survey in salesforce.com for a challenge
  # * *Args*    :
  #   - access_token -> the oauth token to use
  #   - chalelnge_id -> the id of the challenge
  #   - data -> hash of values containing survey responses
  # * *Returns* :
  #   - a hash containing the following keys: success, message
  # * *Raises* :
  #   - ++ ->
  #   
  def self.create(access_token, challenge_id, data)
  	set_header_token(access_token) 
    options = {
      :body => {
          :challenge => challenge_id,
          :compete_again => data[:compete_again],
          :prize_money => data[:prize_money],
          :requirements => data[:requirements],
          :timeframe => data[:timeframe],
          :why_no_submission => data[:why_no_submission],
          :improvements => data[:improvements]
      }
    }
    results = post(ENV['SFDC_APEXREST_URL']+'/surveys', options)
    {:success => results['Success'], :message => results['Message']}
  end

end