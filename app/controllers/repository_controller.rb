#This Controller is in charge of the repository management.
#Basically, It enable/disable a repository or list all of them.
#Author: Samur Araujo
#Date: 25 jun 2008.
class RepositoryController < ApplicationController  
  # The index method get the list of all adapter in the pool.
  #list all adapters registered in the pool.
  @repositories
  def index    
    
    render :layout => false
  end
  def autoadd
    FinderUtil.find_and_add(params[:uri].gsub('>','').gsub('<',''))
    render :text => ''
  end
  def autodiscovery
    
    session[:autodiscovery] = params[:flag] 
    
    render :text => ''
  end
  def queryRetrieveLabelAndType
    
    if  params[:flag] =='true'
      Thread.current[:query_retrieve_label_and_type]=session[:query_retrieve_label_and_type]=true
      Thread.current[:label_properties]=session[:label_properties]=['rdfs::label']
    else
      Thread.current[:query_retrieve_label_and_type]=session[:query_retrieve_label_and_type]=false
      Thread.current[:label_properties]=session[:label_properties]=$LABEL_PROPERTIES
    end
      render :text => ''
  end
  
  def limit
    adapters = ConnectionPool.adapters()
    adapters.each do |repository|
      #create a model repository passing the repository's id, title and enableness 
      if repository.title == params[:title]
        
        repository.limit=params[:limit].rstrip
        repository.limit=nil if repository.limit == 0 || repository.limit ==''
        
      end
    end       
    render :text => '',:layout => false
  end
  #The disable method disable a adapter.
  #disable a specific adapter in the ConnectionPool.
  def enable
    RDFS::Resource.reset_cache()     
    session[:enablerepositories] << (params[:title]) 
    session[:enablerepositories].uniq!
    session[:triples]=Hash.new
#      Repository.disable_by_title(params[:title])
    #render nothing.
    render :text => '',:layout => false    
  end
  #The enable method enable a adapter.
  #enable a specific adapter in the ConnectionPool.
  def disable     
    puts  request.session_options[:id]
           
    session[:enablerepositories].delete(params[:title])        
    session[:triples]=Hash.new 
#     Repository.enable_by_title(params[:title])
    #render nothing.
  
    render :text => '',:layout => false
  end
  
  def add
    if params[:title]==nil || params[:title]  == ''
      redirect_to :controller => 'message',:action => 'error', :message => "Type the SPARQL Enpoint title",:layout => false
      return
    end
    begin
      adapter = ConnectionPool.add_data_source :title =>params[:title] , :type => :sparql, :url => params[:uri], :results => :sparql_xml, :caching =>true   
      
      adapter.limit=params[:limit]  if params[:limit] != nil && params[:limit].rstrip != ''  
      session[:addrepositories]<< adapter
      session[:enablerepositories] << (params[:title]) 
      session[:enablerepositories].uniq!
      
      
    rescue Exception => e
      puts e.message
      puts e.backtrace
      
      session[:addrepositories].delete(adapter)
      session[:enablerepositories].delete(params[:title]) 
      ConnectionPool.remove_data_source(adapter)
      #      render_component :controller => 'message',:action => 'error', :message => "SPARQL Enpoint invalid: "+e.message ,:layout => false
      redirect_to :action => 'endpointsform' , :message => "SPARQL Enpoint invalid: "+e.message ,:layout => false
      return
    end
    begin 
      
      # construct the necessary Ruby Modules and Classes to use the Namespace
      ObjectManager.construct_classes
      
      #Test the sparql endpoint.
      Query.new.distinct(:s).where(:s,Namespace.lookup(:rdf,:type),Namespace.lookup(:rdfs,:Class)).limit(5).execute      
    rescue Exception => e
      puts e.message
      puts e.backtrace
      session[:addrepositories].delete(adapter)
      session[:enablerepositories].delete(params[:title]) 
      ConnectionPool.remove_data_source(adapter)
      redirect_to :action => 'endpointsform' ,:message => e.message ,:layout => false
      return
      #       render_component :controller => 'message',:action => 'error',:message => e.message ,:layout => false
    end
    session[:triples]=Hash.new
    redirect_to :action => 'endpointsform',:message => 'Sparql endpoint added successfully!' ,:messageaction=>'confirmation'
    
  end
  def listenabledrepositories
    render :partial => 'listenabledrepositories',:layout =>false
  end
  
  def endpointsform
    #variable that will store the list of adapters.
    @repositories = Array.new
    @message = params[:message]
    
    #Gets all adapters    
    adapters = ConnectionPool.adapters()
    adapters.each do |repository|
      #create a model repository passing the repository's id, title and enableness 
      if repository.title!= 'INTERNAL' && (repository.title.index('(Local)') || session[:addrepositories].include?(repository))
        @repositories <<  Repository.new(repository.object_id,repository.title, session[:enablerepositories].include?(repository.title),repository.limit)
      end
    end           
    @repositories.each{|r| 
     puts r.title + " " + r.enable.to_s
    
    }
    render :layout =>false
  end
end
