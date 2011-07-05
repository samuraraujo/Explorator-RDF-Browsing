# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.
class ExploratorError < Exception
end
class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time  
  before_filter :session_init
  #global attribute use for all explorator controllers
  @resourceset
  
  def session_init    
       puts request.session_options[:id]
    puts session[:application] 
    if session[:application] == nil       
      
      session[:enablerepositories]=Array.new
 
      session[:enablerepositories] << 'INTERNAL'
  
      session[:addrepositories] = Array.new
      session[:triples]=Hash.new
   
      session[:application] =  Application.new(request.session_options[:id])
      session[:query_retrieve_label_and_type]=$QUERY_RETRIEVE_LABEL_AND_TYPE
      session[:label_properties]=$LABEL_PROPERTIES
    end
       
    Thread.current[:triples]=session[:triples]
    Thread.current[:addrepositories]=session[:addrepositories]
    Thread.current[:enablerepositories]=session[:enablerepositories]    
    Thread.current[:application]=session[:application]
    Thread.current[:autodiscovery]=session[:autodiscovery]  
    Thread.current[:query_retrieve_label_and_type]=session[:query_retrieve_label_and_type]
    Thread.current[:label_properties]=session[:label_properties]
  end  
  #This was set to false for enable ajaxs request over post HTTP method.
  self.allow_forgery_protection = false  
  def index    
    @applications = EXPLORATOR::Application.find_by_explorator::uuid(session[:application].uri)
    render :action => 'index', :layout =>false
  end
  def reset 
    session[:application].clear
    redirect_to :controller => 'explorator' 
  end
  def create
    session[:application].create(params[:name])  
    redirect_to :controller => "explorator"
  end
  def restore 
    session[:application].load(params[:uri])  
    redirect_to :controller => "explorator"
    # render :template => 'explorator/index'
  end
  def delete
    session[:application].delete(params[:uri])  
  end
  
  def get_adapter(name)    
    adapter = ConnectionPool.adapters.select {|adapter| 
      adapter.title == name
    }
    adapter.first()
  end
end
