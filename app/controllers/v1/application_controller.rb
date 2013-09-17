include ActionController::HttpAuthentication::Token::ControllerMethods
require 'new_relic/agent/instrumentation/rails3/action_controller'

class V1::ApplicationController < RocketPants::Base

  include NewRelic::Agent::Instrumentation::ControllerInstrumentation
  include NewRelic::Agent::Instrumentation::Rails3::ActionController  

  before_filter :set_oauth_token

  # initiliaze default fields for CloudSpokes API request -- include '__c' for each field
  DEFAULT_MEMBER_FIELDS         = 'id,name,school__c,years_of_experience__c,gender__c,time_zone__c,profile_pic__c,country__c,summary_bio__c,quote__c,challenges_entered__c,total_money__c,website__c,twitter__c,linkedin__c,icq__c,jabber__c,github__c,facebook__c,digg__c,myspace__c,total_wins__c,total_points__c,total_1st_place__c,total_2nd_place__c,total_3st_place__c,valid_submissions__c,badgeville_id__c,active_challenges__c'
  MEMBER_SEARCH_FIELDS          = 'id,name,profile_pic__c,summary_bio__c,challenges_entered__c,active_challenges__c,total_wins__c,total_1st_place__c,total_2nd_place__c,total_3st_place__c,total_money__c'
  DEFAULT_RECOMMENDATION_FIELDS = 'recommendation_from__r.name,recommendation_from__r.profile_pic__c,recommendation__c,createddate'
  DEFAULT_CHALLENGE_FIELDS      = 'id,name,createddate,description__c'
  DEFAULT_PAYMENT_FIELDS        = 'id,name,challenge__r.name,challenge__r.challenge_id__c,money__c,place__c,reason__c,status__c,type__c,Reference_Number__c,payment_sent__c'

  # Checks for an oauth_token in the header and if it find it, set it
  # to be used for all requests to db.com. If not found, it uses the
  # public oauth_token for all requests to db.com.
  def set_oauth_token
    # use the access token if sent in the headers
    if request.headers['oauth_token']     
      puts "[INFO][Application] Using passed oauth token"      
      @oauth_token = request.headers['oauth_token'].split(':').first
      puts "[INFO][Application] OAuth token: #{@oauth_token}"    
    # fetch the public token from cache (if present) or sfdc
    else
      puts "[INFO][Application] Fetching new oauth token"
      @oauth_token = public_oauth_token
    end
  end

  # Checks for the api_key passed in the header. If the api_key
  # from the header is found in the local database then access
  # is granted to the route. If not, returns a 401.
  def restrict_access
    puts "[INFO][Application] Checking for API key"
    authorized = ApiKey.exists?(access_key: api_key_from_header)
    puts "[INFO][Application] Access authorized? #{authorized}"
    error! :unauthenticated if !authorized
  end   

  # for 'order_by' params, it could be passed as 'wins desc'
  # so need to enforce 'wins' and not desc
  def enforce_order_by_params(order_by, default_return)
    if order_by
      if order_by.split(' ').length.eql?(1)
        Forcifier::FieldMassager.enforce_fields(order_by)
      else 
        # if it has something like 'wins desc'
        Forcifier::FieldMassager.enforce_fields(order_by.split(' ').first) + ' ' + order_by.split(' ').second
      end
    else
      default_return
    end    
  end  

  private

    # parses the api_key from the Authorization request header:
    # request.env['Authorization'] = 'Token token="THIS-IS-MY-TOKEN"'
    def api_key_from_header
      token = ''
      if request.headers['Authorization'] 
        begin 
          token = request.headers['Authorization'].split('=').second.gsub('"','')
        rescue
        end
      end
      token
    end

    # returns a 'public' access token from db.com authentication unless it exists in the cache
    def public_oauth_token
      public_oauth_token = Rails.cache.fetch('pubic_oauth_token', :expires_in => 30.minute) do
        puts '[APPLICATION_CONTROLLER][INFO] Fetching public access token from sfdc'
        client = Restforce.new :username => ENV['SFDC_PUBLIC_USERNAME'],
          :password       => ENV['SFDC_PUBLIC_PASSWORD'],
          :client_id      => ENV['DATABASEDOTCOM_CLIENT_ID'],
          :client_secret  => ENV['DATABASEDOTCOM_CLIENT_SECRET'],
          :host           => ENV['DATABASEDOTCOM_HOST']
        client.authenticate!.access_token
      end 
    end  

    # returns an 'admin' access token from db.com authentication
    def admin_oauth_token
      puts '[APPLICATION_CONTROLLER][INFO] Fetching admin access token from sfdc'
      client = Restforce.new :username => ENV['SFDC_ADMIN_USERNAME'],
        :password       => ENV['SFDC_ADMIN_PASSWORD'],
        :client_id      => ENV['DATABASEDOTCOM_CLIENT_ID'],
        :client_secret  => ENV['DATABASEDOTCOM_CLIENT_SECRET'],
        :host           => ENV['DATABASEDOTCOM_HOST']
      client.authenticate!.access_token      
    end      

end