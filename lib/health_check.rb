module HealthCheck

	def self.status(challenge, comments)

    days_till_close = challenge['days_till_close']    
    registered_members = challenge['registered_members']
    participating_members = 0 

    status = :yellow
    if days_till_close <= 2
      status = :green if registered_members >= 3
      status = :red if registered_members <= 1
    elsif days_till_close <= 4
      number_of_comments = public_comments_count(comments)
      status = :green if number_of_comments >= 4 && registered_members <= 1
      status = :green if registered_members >= 2
      status = :red if registered_members == 0
    elsif days_till_close <= 6
      status = :green if registered_members > 2
    end 		
    status

	end

  private 

    def self.public_comments_count(comments)
      public_comments = 0
      comments.each do |c|
        public_comments = public_comments + 1 unless c['member__r']['email'].include?('@appirio.com')
      end
      public_comments
    end  	

end