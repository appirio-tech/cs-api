require 'spec_helper'

describe V1::StatsController do	

	describe "stats" do
		it "should return successfully" do
			VCR.use_cassette "controllers/v1/stats/success" do
				get 'public'
				response.should be_success	
			end
		end						
	end 

end