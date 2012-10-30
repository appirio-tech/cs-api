require 'spec_helper'

describe V1::LeaderboardController do	

	describe "leaderboard" do
		it "should return results successfully without options" do
			VCR.use_cassette "controllers/v1/leaderboard/results_no_options" do
				get 'index'
				response.should be_success
				h = JSON.parse(response.body)
				h['count'].should > 0			
			end
		end
	end 

end