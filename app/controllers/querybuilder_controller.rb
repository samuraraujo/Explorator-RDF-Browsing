class QuerybuilderController < ApplicationController 
  def index   
    
    @resource =  Namespace.lookup(:rdfs,:Resource)
    render :action => 'index', :layout => false
  end
  def resource  
     @resource = RDFS::Resource.new(params[:uri])
     render :partial => 'rdfresource' 
 end
  def property  
     @resource = RDFS::Resource.new(params[:uri])
     render :partial => 'property' 
 end
  def relation          
     @resource = RDFS::Resource.new(params[:uri]) 
     render :partial => 'relation' 
  end
end
