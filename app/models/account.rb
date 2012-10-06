class Account < Salesforce

  #
  # Uses the databasedotcom gem to authenticates a user 
  # with sfdc and return a session token
  # * *Args*    :
  #   - access_token -> the oauth token to use
  #   - membername -> the cloudspokes member name to authenticate
  #   - password -> the member's sfdc password
  # * *Returns* :
  #   - JSON containing the following keys: access_token, success, message
  # * *Raises* :
  #   - ++ ->
  #  
	def self.authenticate(access_token, membername, password)
    config = YAML.load_file(File.join(::Rails.root, 'config', 'databasedotcom.yml'))
    client = Databasedotcom::Client.new(config)
    sfdc_username = membername+'@'+ENV['SFDC_USERNAME_DOMAIN']
    begin
    	puts "[INFO][Account] Logging into salesforce with sfdc username: #{sfdc_username}"
      access_token = client.authenticate :username => sfdc_username, :password => password
      puts "[INFO][Account] Successful login for #{membername} with sfdc username #{sfdc_username}."
      {:success => 'true', :message => 'Successful sfdc login.', :access_token => access_token}
    rescue Exception => exc
      puts "[FATAL][Account] Could not log into salesforce using gem to get access_token for #{membername}: #{exc.message}"
      {:success => 'false', :message => exc.message}
    end

	end

  #
  # Activites a user and returns the users info. only sysadmin profiles
  # should be able to run this. Non-SysAdmin will throw an error as they
  # do not have access to all fields (account__c) if fetching a 
  # 'cloudspokes' user account.
  # * *Args*    :
  #   - access_token -> the oauth token to use
  #   - membername -> the cloudspokes member name (mess) to find
  #   - service -> the thirdparty or 'cloudspokes' service
  # * *Returns* :
  #   - JSON containing the following keys: username, sfdc_username, success
  #     profile_pic, email and accountid
  # * *Raises* :
  #   - ++ ->
  #  
	def self.find_by_service(access_token, service, service_name)
		set_header_token(access_token) 

		# cloudspokes credentials
		if service.downcase.eql?('cloudspokes')

	    activate_results = get(ENV['SFDC_APEXREST_URL']+'/activate/'+service_name)
	    puts "[INFO][Account] activating user #{service_name}: #{activate_results}"

	    # do rest query and find member and all their info
			query_results = soql_query("select id, name, profile_pic__c, email__c, 
				sfdc_user__r.username, account__c from member__c 
				where username__c='" + service_name + "' and 
        sfdc_user__r.third_party_account__c = ''")
			
			if query_results['totalSize'].eql?(0)
        puts "[WARN][Account] Query returned no CloudSpokes managed member for #{service_name}." 
				{:success => 'false', :message => "CloudSpokes managed member not found for #{service_name}."}
			else
				m = query_results['records'].first
				{:success => 'true', :username => m['Name'], :sfdc_username => m['SFDC_User__r']['Username'], 
					:profile_pic => m['Profile_Pic__c'], :email => m['Email__c'], :accountid => m['Account__c']}
			end
			
		# third party credentials -- activating user is part of credentials service
		else   

	    options = {
	      :query => {
	          :username => service_name,
	          :service  => service
	      }
	    }

	    results = get(ENV['SFDC_APEXREST_URL']+'/credentials', options)

	    begin
	      if results['Success'].eql?('true')
	        {:success => 'true', :username => results['Username'], :sfdc_username => results['SFusername'], 
	          :profile_pic => results['Profile_Pic'], :email => results['Email'], :accountid => results['AccountId']}
	      else
	        {:success => 'false', :message => results['Message']}
	      end
	    # something bad.. probably expired token
	    rescue Exception => exc
	      return {:success => 'false', :message => results[0]['message']}
	    end

		end

	end

  #
  # Create a new member in db.com and send welcome email
  # * *Args*    :
  #   - access_token -> the oauth token to use
  #   - params -> hash containing values to use for new user
  #      - for third-party: provider, provider_username, username, email, name (can be blank)
  #      - for cloudspokes: username, email, password 
  # * *Returns* :
  #   - JSON containing the following keys: username, sfdc_username, success, message 
  # * *Raises* :
  #   - ++ ->
  #  
	def self.create(access_token, params={})
    set_header_token(access_token)
          
    # third party      
    if params.has_key?(:provider)
      
      # if the name if blank
      if params[:name].empty?
        first_name = params[:username]
        last_name = params[:username]
      else
        # split up the name into a first and last
        names = params[:name].split
        first_name = names[0]
        if names.length > 1
          last_name = names[1]
        else
          last_name = first_name
        end
      end
      
      options = {
        :body => {
            :username__c => params[:username],
            :email__c  => params[:email],
            :first_name__c => first_name,
            :last_name__c => last_name,
            :third_party_account__c => params[:provider],
            :third_party_username__c => params[:provider_username]
        }
      }
    
    # cloudspokes        
    else

      options = {
        :body => {
            :username__c => params[:username],
            :password => params[:password],
            :email__c  => params[:email],
            :first_name__c => params[:username],
            :last_name__c => params[:username] 
        }
      }

    end    
    
    puts "[INFO][Account] Making the call to create the user for #{options}"  
    new_account_results = post(ENV['SFDC_APEXREST_URL']+'/members', options)
                
    begin
      puts "[INFO][Account] Results from the create new user call: #{new_account_results}" 
      if new_account_results['Success'].eql?('true')
        success_results =  {:success => 'true', 
        	:username => new_account_results["username"], 
          :sfdc_username => new_account_results["sfdc_username"], 
          :message => new_account_results["Message"]}

        # send the welcome email
        puts "[INFO][Account] Sending new member 'Welcome Email' to #{params[:email]}" 
        MemberMailer.welcome_email(params[:username],params[:email]).deliver          
        success_results
      else
        puts "[WARN][Account] Could not create new user. sfdc replied: #{new_account_results["Message"]}" 
        {:success => 'false', :message => new_account_results["Message"]}
      end
    rescue Net::SMTPAuthenticationError, Net::SMTPServerBusy, Net::SMTPSyntaxError, Net::SMTPFatalError, Net::SMTPUnknownError => e      
      puts "[FATAL][Account] SMTP Error sending 'Welcome Email'! Cause: #{e.message}"   
      success_results
    rescue
      puts "[FATAL][Account] Error creating new user: #{new_account_results[0]['message']}" 
      {:success => 'false', :message => new_account_results[0]['message']}
    end   

  end	

  #
  # Creates a passcode in salesforce for resetting a member's password and sends email via Apex. 
  # Only works if member is using CloudSpokes to manage their account.
  # * *Args*    :
  #   - access_token -> the oauth token to use
  #   - membername -> the cloudspokes member name (mess) to reset
  # * *Returns* :
  #   - JSON containing the following keys: success, message
  # * *Raises* :
  #   - ++ ->
  #  
  def self.reset_password(access_token, membername)
    set_header_token(access_token)
    results = post(ENV['SFDC_APEXREST_URL'] + "/password/reset?username=#{esc membername}",:body => {})
    {:success => results['Success'], :message => results['Message']}
  end

  #
  # Resets a member's password in salesforce is CloudSpokes is managing their account.
  # * *Args*    :
  #   - access_token -> the oauth token to use
  #   - membername -> the cloudspokes member name (mess) to reset
  #   - passcode -> the passcode sent to them via email
  #   - new_password -> the new password to change their account to
  # * *Returns* :
  #   - JSON containing the following keys: success, message
  # * *Raises* :
  #   - ++ ->
  #  
  def self.update_password(access_token, membername, passcode, new_password)
    set_header_token(access_token)
    results = put(ENV['SFDC_APEXREST_URL'] + "/password/reset?username=#{esc membername}&passcode=#{passcode}&newpassword=#{esc new_password}",:body => {}) 
    {:success => results['Success'], :message => results['Message']}
  end  

  #
  # Activates a member and their sfdc account
  # * *Args*    :
  #   - access_token -> the oauth token to use
  #   - membername -> the cloudspokes member name (mess)
  # * *Returns* :  
  #   - boolean
  # * *Raises* :
  #   - ++ ->
  #  
  def self.activate(access_token, membername)
    set_header_token(access_token)
    results = get(ENV['SFDC_APEXREST_URL'] + "/activate/#{membername}") 
    if results['Success'].eql?('true') 
      puts "[INFO][Account] #{membername} successfully activated in sfdc." 
      true
    else
      puts "[FATAL][Account] Could not activate #{membername} in sfdc: #{results}" 
      false
    end
  end 

end