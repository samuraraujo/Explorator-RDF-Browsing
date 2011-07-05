class MessageController < ApplicationController
  def error     
    @message=params[:message]
    render :layout => false
  end
    def confirmation
    @message=params[:message]
    render :layout => false
  end
end
