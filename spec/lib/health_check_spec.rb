require 'spec_helper'
require 'health_check'

describe HealthCheck do

  describe "status for <= 2 days" do
    it "should be yellow if two registered members" do
      challenge = {'days_till_close' => 2, 'registered_members' => 2}
      comments = [{ 'member__r' => {'email' => 'jeff@jeffdouglas.com'} }]
      status = HealthCheck.status(challenge, comments)
      status.should == :yellow
    end
    it "should be green for 4 registered members" do
      challenge = {'days_till_close' => 2, 'registered_members' => 4}
      comments = [{ 'member__r' => {'email' => 'jeff@jeffdouglas.com'} }]
      status = HealthCheck.status(challenge, comments)
      status.should == :green
    end
    it "should be red if no registered members" do
      challenge = {'days_till_close' => 2, 'registered_members' => 0}
      comments = [{ 'member__r' => {'email' => 'jeff@jeffdouglas.com'} }]
      status = HealthCheck.status(challenge, comments)
      status.should == :red
    end
  end   
  
  describe "status for 3 days" do
    it "should be yellow if one registered member and one comment" do
      challenge = {'days_till_close' => 3, 'registered_members' => 1}
      comments = [{ 'member__r' => {'email' => 'jeff@jeffdouglas.com'} }]
      status = HealthCheck.status(challenge, comments)
      status.should == :yellow
    end
    it "should be green if one registered member and four comments" do
      challenge = {'days_till_close' => 3, 'registered_members' => 1}
      comments = []
      comments << { 'member__r' => {'email' => 'jeff@jeffdouglas.com'} }
      comments << { 'member__r' => {'email' => 'jeff@jeffdouglas.com'} }
      comments << { 'member__r' => {'email' => 'jeff@jeffdouglas.com'} }
      comments << { 'member__r' => {'email' => 'jeff@jeffdouglas.com'} }
      status = HealthCheck.status(challenge, comments)
      status.should == :green
    end    
    it "should be green if there are three registered member and zero comments" do
      challenge = {'days_till_close' => 3, 'registered_members' => 2}
      status = HealthCheck.status(challenge, [])
      status.should == :green
    end        
    it "should be red if there are zero registered member and zero comments" do
      challenge = {'days_till_close' => 3, 'registered_members' => 0}
      status = HealthCheck.status(challenge, [])
      status.should == :red
    end     
    it "should be yellow if one registered member and four comments but one is from appiro" do
      challenge = {'days_till_close' => 3, 'registered_members' => 1}
      comments = []
      comments << { 'member__r' => {'email' => 'jeff@appirio.com'} }
      comments << { 'member__r' => {'email' => 'jeff@jeffdouglas.com'} }
      comments << { 'member__r' => {'email' => 'jeff@jeffdouglas.com'} }
      comments << { 'member__r' => {'email' => 'jeff@jeffdouglas.com'} }
      status = HealthCheck.status(challenge, comments)
      status.should == :yellow
    end    
  end 

  describe "status for 5 days" do
    it "should be yellow if one registered members" do
      challenge = {'days_till_close' => 5, 'registered_members' => 1}
      status = HealthCheck.status(challenge, [])
      status.should == :yellow
    end
    it "should be green if three registered members" do
      challenge = {'days_till_close' => 5, 'registered_members' => 3}
      status = HealthCheck.status(challenge, [])
      status.should == :green
    end    
  end         

end