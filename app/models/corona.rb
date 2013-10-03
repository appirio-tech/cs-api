class Corona  < Salesforce

  def self.create(access_token, params)
    create_results = create_in_salesforce(access_token, 'CDF_Activity__c', {
        'content__c' => params['content'], 
        'country__c' => params['country'], 
        'data_type__c' => params['eventType'],
        'latitude__c' => params['lat'], 
        'longitude__c' => params['long'], 
        'profile_pic__c' => params['profile_pic']
      }
    )
    {:success => create_results[:success]}
  end

end   