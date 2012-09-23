class Account < Salesforce

	# log into sfdc with their credentials to return their access token
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
  #   - JSON containing user info
  # * *Raises* :
  #   - ++ ->
  #  
	def self.find_by_membername_and_service(access_token, membername, service)
		set_header_token(access_token) 

		# cloudspokes credentials
		if service.downcase.eql?('cloudspokes')

	    activate_results = get(ENV['SFDC_APEXREST_URL']+'/activate/'+membername)
	    puts "[INFO][Account] activating user #{membername}: #{activate_results}"

	    # do rest query and find member and all their info
			query_results = soql_query("select id, name, profile_pic__c, email__c, 
				sfdc_user__r.username, account__c from member__c 
				where username__c='" + membername + "' and 
        sfdc_user__r.third_party_account__c = ''")
			
			if query_results['totalSize'].eql?(0)
        puts "[WARN][Account] Query returned no CloudSpokes managed member for #{membername}." 
				{:success => 'false', :message => "CloudSpokes managed member not found for #{membername}."}
			else
				m = query_results['records'].first
				{:success => 'true', :username => m['Name'], :sfdc_username => m['SFDC_User__r']['Username'], 
					:profile_pic => m['Profile_Pic__c'], :email => m['Email__c'], :accountid => m['Account__c']}
			end
			
		# third party credentials -- activating user is part of credentials service
		else   

	    options = {
	      :query => {
	          :username => membername,
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
        {:success => 'true', 
        	:username => new_account_results["username"], 
          :sfdc_username => new_account_results["sfdc_username"], 
          :message => new_account_results["Message"]}
      else
        puts "[WARN][Account] Could not create new user. sfdc replied: #{new_account_results["Message"]}" 
        {:success => 'false', :message => new_account_results["Message"]}
      end
    rescue
      puts "[FATAL][Account] Error creating new user: #{new_account_results[0]['message']}" 
      {:success => 'false', :message => new_account_results[0]['message']}
    end   

  end	

end