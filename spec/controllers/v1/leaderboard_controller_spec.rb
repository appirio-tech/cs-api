require 'spec_helper'

describe V1::LeaderboardController do	

	describe "leaderboard" do
		it "should return results successfully without options" do
			VCR.use_cassette "controllers/v1/leaderboard/results_no_options" do
				get 'public'
				response.should be_success
				h = JSON.parse(response.body)
				h['count'].should >= 0			
			end
		end

		it "should return results successfully with options" do
			VCR.use_cassette "controllers/v1/leaderboard/results_with_options" do
				get 'public', 'category' => 'heroku', 'period' => 'month'
				response.should be_success
			end
		end

		it "should return results successfully with category" do
			VCR.use_cassette "controllers/v1/leaderboard/results_with_category" do
				get 'public', 'category' => 'heroku'
				response.should be_success
			end
		end		

		it "should return results successfully with period" do
			VCR.use_cassette "controllers/v1/leaderboard/results_with_period" do
				get 'public', 'period' => 'month'
				response.should be_success
			end
		end				
	end 
	

end