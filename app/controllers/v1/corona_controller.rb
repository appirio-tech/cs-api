class V1::CoronaController < V1::ApplicationController

  before_filter :restrict_access

  def create
    expose Corona.create(@oauth_token, params['data'])
  end 

end
