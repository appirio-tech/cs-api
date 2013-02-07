class Account < Salesforce

  #
  # Uses the restforce gem to authenticates a user 
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
    sfdc_username = membername+'@'+ENV['SFDC_USERNAME_DOMAIN']
    client = Restforce.new :username => sfdc_username,
      :password       => password,
      :client_id      => ENV['DATABASEDOTCOM_CLIENT_ID'],
      :client_secret  => ENV['DATABASEDOTCOM_CLIENT_SECRET'],
      :host           => ENV['DATABASEDOTCOM_HOST']
    begin
      puts "[INFO][Account] Logging into salesforce with sfdc username: #{sfdc_username}"
      access_token = client.authenticate!.access_token
      puts "[INFO][Account] Successful login for #{membername} with sfdc username #{sfdc_username}."
      {:success => 'true', :message => 'Successful sfdc login.', :access_token => access_token}
    rescue Exception => exc
      puts "[FATAL][Account] Could not log into salesforce using gem to get access_token for #{membername}: #{exc.message}"
      {:success => 'false', :message => exc.message}
    end
  end

  #
  # Finds a member's account info by their membername.
  # * *Args*    :
  #   - access_token -> the oauth token to use
  #   - membername -> the cloudspokes member name (mess) to find
  # * *Returns* :
  #   - JSON containing the following keys: username, sfdc_username, success
  #     profile_pic, email and accountid
  # * *Raises* :
  #   - ++ ->
  #  
  def self.find(access_token, membername)
    set_header_token(access_token) 
    # do rest query and find member and all their info
    query_results = query_salesforce(access_token, "select id, name, profile_pic__c, email__c, 
      sfdc_user__r.username, account__c from member__c 
      where username__c='" + membername + "'")

    unless query_results.empty?
      m = query_results.first
      {:success => 'true', :username => m['name'], :sfdc_username => m['sfdc_user__r']['username'], 
      :profile_pic => m['profile_pic'], :email => m['email'], :accountid => m['account']}
    else        
      puts "[WARN][Account] Account not found for #{membername}." 
      {:success => 'false', :message => "Account not found for #{membername}."}
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
    if service.downcase.eql?('cloudspokes')
      activate_cloudspokes(access_token, service_name)
    else   
      activate_third_party(access_token, service, service_name)
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
            
    options = create_options(params)
    puts "[INFO][Account] Making the call to create the user for #{options}"  
    new_account_results = post_apex_rest('/members', options)
                
    begin
      puts "[INFO][Account] Results from the create new user call: #{new_account_results}" 
      if new_account_results['success'].eql?('true')
        success_results =  {:success => 'true', 
          :username => new_account_results['username'], 
          :sfdc_username => new_account_results['sfdc_username'], 
          :message => new_account_results['message']}

        # send the welcome email
        if ENV['WELCOME_EMAIL_SENDER'].eql?('enabled')
          puts "[INFO][Account] Sending new member 'Welcome Email' to #{params[:email]}" 
          MemberMailer.welcome_email(params[:username],params[:email]).deliver          
        end
        success_results
      else
        puts "[WARN][Account] Could not create new user. sfdc replied: #{new_account_results["message"]}" 
        {:success => 'false', :message => new_account_results['message']}
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
  # Changes member's password in salesforce if CloudSpokes is managing their account.
  # * *Args*    :
  #   - access_token -> the oauth token to use
  #   - membername -> the cloudspokes member name (mess) to reset
  #   - new_password -> the new password to change their account to
  # * *Returns* :
  #   - JSON containing the following keys: success, message
  # * *Raises* :
  #   - ++ ->
  #  
  def self.update_password_token(access_token, membername, token)
    set_header_token(access_token)
    # get the id of the user to make life a little harder
    user_results = query_salesforce(access_token, "select id from user 
      where id in (select sfdc_user__c from member__c where name = '#{membername}')")
    data = {:id => user_results.first.id, :token => token}
    results = put(ENV['SFDC_APEXREST_URL'] + "/password-change?#{data.to_param}") 
    {:success => results['Success'], :message => results['Message']}
  rescue Exception => e
    {:success => 'false', :message => "Error updating passcode." }
  end     

  #
  # Changes member's password in salesforce if CloudSpokes is managing their account.
  # * *Args*    :
  #   - access_token -> the oauth token to use
  #   - membername -> the cloudspokes member name (mess) to reset
  #   - new_password -> the new password to change their account to
  # * *Returns* :
  #   - JSON containing the following keys: success, message
  # * *Raises* :
  #   - ++ ->
  #  
  def self.change_password_with_token(access_token, membername, token, new_password)
    set_header_token(access_token)
    # get the id of the user to make life a little harder
    user_results = query_salesforce(access_token, "select id from user 
      where id in (select sfdc_user__c from member__c where name = '#{membername}')")
    data = {:id => user_results.first.id, :token => token, :password => new_password}
    results = put(ENV['SFDC_APEXREST_URL'] + "/password-change?#{data.to_param}") 
    {:success => results['Success'], :message => results['Message']}
  rescue Exception => e
    {:success => 'false', :message => "Error changing password." }
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
    get_apex_rest_return_boolean("/activate/#{membername}")
  end 

  #
  # Disables a member and their sfdc account
  # * *Args*    :
  #   - access_token -> the oauth token to use
  #   - membername -> the cloudspokes member name (mess)
  # * *Returns* :  
  #   - boolean
  # * *Raises* :
  #   - ++ ->
  #  
  def self.disable(access_token, membername)
    set_header_token(access_token)
    get_apex_rest_return_boolean("/disable/#{membername}")
  end   

  private

    def self.create_options(params)

      options = {
        :body => {
            :username__c => params[:username],
            :email__c  => params[:email]
        }
      }      

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
          last_name = first_name
          last_name = names[1] if names.length > 1
        end
        
        new_options = {
          :first_name__c => first_name,
          :last_name__c => last_name,
          :third_party_account__c => params[:provider],
          :third_party_username__c => params[:provider_username]
        }
      
      # cloudspokes        
      else

        new_options = {
          :password => params[:password],
          :first_name__c => params[:username],
          :last_name__c => params[:username] 
        }

      end 
      options[:body].merge!(new_options)  
      options 

    end

    def self.activate_third_party(access_token, service, service_name)

      options = {
        :query => {
        :username => service_name,
        :service  => service
        }
      }

      results = get(ENV['SFDC_APEXREST_URL']+'/credentials', options)

      begin
        if results['Success'].eql?('true')
          {:success => 'true', :username => results['Username'], 
            :sfdc_username => results['SFusername'], 
            :profile_pic => results['Profile_Pic'], 
            :email => results['Email'], 
            :accountid => results['AccountId']}
        else
          {:success => 'false', :message => results['Message']}
        end
      # something bad.. probably expired token
      rescue Exception => exc
        {:success => 'false', :message => results[0]['message']}
      end

    end

    def self.activate_cloudspokes(access_token, service_name)
      activate_results = get_apex_rest("/activate/#{service_name}")
      puts "[INFO][Account] activating user #{service_name}: #{activate_results}"

      # do rest query and find member and all their info
      query_results = query_salesforce(access_token, "select id, name, profile_pic__c, email__c, 
        sfdc_user__r.username, account__c from member__c 
        where username__c='" + service_name + "' and 
        sfdc_user__r.third_party_account__c = ''")

      unless query_results.empty?
        m = query_results.first
        {:success => 'true', :username => m['name'], :sfdc_username => m['sfdc_user__r']['username'], 
        :profile_pic => m['profile_pic'], :email => m['email'], :accountid => m['account']}
      else        
        puts "[WARN][Account] Query returned no CloudSpokes managed member for #{service_name}." 
        {:success => 'false', :message => "CloudSpokes managed member not found for #{service_name}."}
      end
    end

end