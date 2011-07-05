#This Controller just is used to supply the css's user interface 
#Author: Samur Araujo
#Date: 25 jun 2008.
class CssController < ApplicationController
  #Default rails method for a controller.
  def index    
    render :action => 'index', :layout =>false
  end
end
