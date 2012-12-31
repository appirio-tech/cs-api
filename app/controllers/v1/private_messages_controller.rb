class V1::PrivateMessagesController < V1::ApplicationController

	# inherit from actual member model. Categories in this controller uses the
	# subclass so we can overrid any functionality for this version of api.
	class PrivateMessage < ::PrivateMessage

	end	

  def all
    expose PrivateMessage.all(@oauth_token)
  end	

  def find
    expose PrivateMessage.find(@oauth_token, params[:id])
  end  

  def create
    expose PrivateMessage.create(@oauth_token, params[:data])
  end   

  def update
    expose PrivateMessage.update(@oauth_token, params[:id], params[:data])
  end         

  def reply
    expose PrivateMessage.reply(@oauth_token, params[:id], params[:data])
  end    

  def to
    expose PrivateMessage.to(@oauth_token, params[:membername])
  end    

  def from
    expose PrivateMessage.from(@oauth_token, params[:membername])
  end    

  def inbox
    expose PrivateMessage.inbox(@oauth_token, params[:membername])
  end   

end