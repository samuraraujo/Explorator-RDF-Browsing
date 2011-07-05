#This Controller updates a resource view.
#Author: Samur Araujo
#Date: 25 jun 2008.
class ViewerController < ApplicationController
  @setid
  @view
  #changes the view of a resource
  def setviewer   
    #the view script.
   
    view = params[:value]    
    #Gets the first resource in the set and sets the new view for it.
    resource = session[:application].get(params[:setid]).resources[0]  
    #it will add a triple in the repository where the subject will be the resource uri, the predicate
    #will be  explorator:view and the object will be the view script.   
    resource.explorator::view=view     
     
    #render nothing
    render :text => ''
  end
  #the index method return the view for a specific resource.
  def index
    @setid = params[:setid]
    #returns the resource view. Notes that it was passed a set as parameter and not a resource itself.
    @view = session[:application].get(params[:setid]).resources[0].explorator::view
   end
end
