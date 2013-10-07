class Topcoder < Salesforce

  def self.find_by_membername(access_token,membername)
    fields  = 'Id,Name,CreatedDate,LastModifiedDate,LastActivityDate,AIM__c,Address_Line1__c,Address_Line2__c,Age_Range__c,City__c,Company__c,Country__c,Digg__c,Email__c,Facebook__c,First_Name__c,Gender__c,Github__c,ICQ__c,Jabber__c,Challenges_Registered__c,Last_Name__c,LinkedIn__c,MySpace__c,Phone_Home__c,Phone_Mobile__c,Phone_Work__c,Quote__c,Percent_Submitted__c,Percent_Passing_Submission__c,SFDC_User__r.Username,School__c,Shirt_Size__c,State__c,Summary_Bio__c,Appellate_Member__c,Twitter__c,Username__c,Website__c,Work_Status__c,Yahoo__c,Years_of_Experience__c,Zip__c,Challenges_Entered__c,Full_Name__c,Total_Payments_Received__c,Total_1st_Place__c,Total_2nd_Place__c,Total_3st_Place__c,Time_Zone__c,Total_Money__c,Total_Points__c,Profile_Pic__c,Account__c,Total_Wins__c,Paypal_Payment_Address__c,Login_Managed_By__c,Paperwork_Received__c,Paperwork_Year__c,Paperwork_Sent__c,Preferred_Payment__c,Active_Challenges__c,Notes__c,Campaign_Medium__c,Campaign_Name__c,Campaign_Source__c,Badgeville_Id__c,Valid_Submissions__c,Question_Reviewer__c,SFDC_User_Active__c,Can_Judge__c,Summary_Bio_Added__c,Profile_Complete__c,Badgeville_Id_Checked__c,Last_Registration_Date__c,Login_Location__Latitude__s,Login_Location__Longitude__s,Last_Login__c'
    set_header_token(access_token) 
    get_apex_rest("/members/#{esc membername}?fields=#{esc fields}")
  end  

  def self.challenges_open
    Rails.cache.fetch('tc_challenges', expires_in: 30.minutes) do
      tc_challenges = HTTParty::get("http://api.topcoder.com/rest/contests?user_key=#{ENV['TOPCODER_USER_KEY']}&listType=ACTIVE")
      cs_challenges = []
      tc_challenges['data'].each do |c|

        # need to rearrange the date from day.month to month.day
        date_parts = c['submissionEndDate'].split('.')
        end_date = DateTime.parse("#{date_parts[1]}-#{date_parts[0]}-#{date_parts[2]}")

        cs_challenges << { :name => c['contestName'], 
          :challenge_id => c['contestId'],
          :challenge_type => 'TopCoder', 
          :id => c['contestId'], 
          :description => c['description'],
          :start_date => DateTime.now, 
          :end_date => end_date,
          :total_prize_money => c['firstPrize'], 
          :is_open => 'true', 
          :days_till_close => 1,
          :registered_members => c['numberOfRegistrants'], 
          :participating_members => c['numberOfRegistrants'],
          :technologies => [{:name => 'Other'}, {:name => 'TopCoder'}],
          :platforms => [{:name => c['type']}] }
      end
      cs_challenges
    end    
  end

end