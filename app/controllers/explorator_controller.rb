require "date"
require "set"
#This controller handles all users request that performs a changing in the domain model.
#Author: Samur Araujo
#Date: 25 jun 2008.

#module where the SemanticExpression class is defined.
require 'query_builder'
#module where the query class is defined.
require 'query_factory'

class ExploratorController < ApplicationController 
  require_dependency "resource_set"
  require_dependency "explorator_application"
  # attr_accessor :resourceset
  #default rails method. returns the view index.rhtml.
  def index
    if params[:url] != nil      
      begin              
       
        #creates a new set. 
        #the expression must be passed by the uri        
        set = EXPLORATOR::Set.new('http://www.tecweb.inf.puc-rio.br/resourceset/id/' + UUID.random_create.to_s)       
        
        if params[:exp] != nil  
          set.init(SemanticExpression.new.union("'#{params[:url]}'",:p,:o))
          
        else
            RDFS::Resource.reset_cache()     
        session[:enablerepositories] << ('EXPLORATOR(Local)') 
        session[:enablerepositories].uniq!
          session[:triples]=Hash.new
          set.init("SemanticExpression.new.go('"+ params[:url] +"')")
        end
        
        
        #the object @resourceset is a global object that will be used by render
        @resourceset = set   
        view = 'subject_view'  
        
        #render the _window.rhtml view
        render :partial => view,:layout=>true
        
      rescue Exception => e
        puts e.backtrace
        redirect_to :controller => 'message',:action => 'error',:message => e.message ,:layout => true
      end
    end
    
  end
  def resourcefilter
    @resourceset =  Application.get(params[:uri])  
    render  :partial => 'subject_view',:layout=>false;
  end 
  
  
  #change the set name
  def editSetName
    set = session[:application].get(params[:uri])
    set.explorator::name=params[:value]
    render :text => params[:value], :layout=>false
  end
  #  prints the filter screen
  def filter    
    @setid=params[:uri]
    render :partial => 'filter',:layout=>false;
  end
  
  # This create method  a ResourceSet based on the Semantic Expression passed
  # by the parameter 'exp';
  # The exp value must be a valid SemanticExpression class instance.
  #Request sample:
  #/explorator/create?exp=SemanticExpression.new.union(:s,Namespace.lookup(:rdf,:type),Namespace.lookup(:rdfs,:Class))
  def create    
    begin      
#      puts params[:exp]
      #creates a new set. 
      #the expression must be passed by the uri
      
      set = EXPLORATOR::Set.new('http://www.tecweb.inf.puc-rio.br/resourceset/id/' + UUID.random_create.to_s)       
         
      set.init(params[:exp])
           
      #the object @resourceset is a global object that will be used by render
      @resourceset = set     
            
      view = params['view']
            
      view = 'subject_view' if  params['view'] == nil || params['view'] == 'null'
          
      #render the _window.rhtml view
      render :partial => view,:layout=>false;
      
    rescue Exception => e
        puts e.backtrace
        redirect_to :controller => 'message',:action => 'error',:message => e.message ,:layout => false
    end
  end
  # The  update method updates a specfic ResourceSet instance identified by the parameter id.
  # The new value will be defined by the expression passed by the parameter exp.
  # The exp value must be a valid SemanticExpression class instance and the ResourceSet instance
  # must has been defined before.
  def update     
#    puts params[:exp]
    #reevaluate the expression and return the set
    resource = session[:application].get(params[:uri])
    
    resource.expression = params[:exp] 
    
    #the object @resourceset is a global object that will be used by render   
    @resourceset =  session[:application].get(params[:uri]) 
    
    #render the _window.rhtml view
    render :partial => 'subject_view', :layout=>false
  end
  #The execute method  evaluate a ruby expression. 
  #this method is used to invoke another method of Explorator.
  #Basically, the UI call this method passing as the expression a 
  # call to the method refresh or remove.
  def execute
    #eval an expression    
#    puts params[:exp]
    eval (params[:exp])
  end
  
  #The reload method is used to return a specific range of resources from a ResourceSet
  #This method is used by the UI when the user is accessing the paginatition indexes.
  #The UI pass 2 parameters, the ResourceSet id and an offset value.
  def reload  
    #return a specific set of resource considering an offset.
     @resourceset= session[:application].get(params[:uri]).setWithOffset( params[:page])    
       
    #render the _window.rhtml view
    render :partial => params[:view]  , :layout=>false
  end
  
  #The remove method removes a determined ResourceSet from the SetsPool or a specific resource from a ResourceSet
  #This method is called by the execute method, being passing as parameter by the user interface.
  def remove(uri)        
    #for remove only one resource in the context 
    session[:application].remove(uri)    
    render :text => '', :layout=>false
  end
  #The refresh method return a determined ResourceSet from the SetsPool
  #This method is called by the Execute method, being passed as a parameter by the interface.
  def refresh(uri,view=:subject_view, filter='')   
    @resourceset= session[:application].get(uri).setWithOffset(1)    
    @filter=filter
    #render the _window.rhtml view
    render :partial => view.to_s , :layout=>false
  end
  
  #  def addfilter     
  #    @resourceset= session[:application].get(params[:uri])
  #    @resourceset.addFilter("filter('select{|i| i.to_i" + params[:op] +  params[:value]+ "}')")
  #    render :partial => "subject_view" , :layout=>false
  #  end
  
  
end