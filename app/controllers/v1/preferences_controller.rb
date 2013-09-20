class V1::PreferencesController < V1::ApplicationController

  #before_filter :restrict_access

  # inherit from actual member model. Preferences in this controller uses the
  # subclass so we can overrid any functionality for this version of api.
  class Preference < ::Preference

  end	

  def all
    expose Preference.all(@oauth_token, params[:membername])
  end  

  def update
    expose Preference.update(@oauth_token, params[:membername], params)
  end  

end