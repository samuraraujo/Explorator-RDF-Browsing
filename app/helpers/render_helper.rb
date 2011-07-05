#The Explorator Helper has several methods used by the files.rhtml.
#Basically, Its methods help the view to hender a RDFS::Resource.
#Author: Samur Araujo
#Date: 25 jun 2008.
module RenderHelper
  #gets the name of the resource
  def   truncate(text)
    if text.instance_of? Array
      text[0]
    else 
      #    max = 21    
      #    if text.to_s.size > max
      #      text.to_s[0, max]  << '...'
      #    else
      #      text.to_s[0, max]  
      #    end        
      
      text
    end
    
  end
  ##sorts the resources using render_resource label
  
  #Render a resource view. 
  # The heuristic used is the following:
  #If was defined a resource view than render it, else render the first resource type's view. 
  def render_resource (resource)       
    return truncate(resource) if !(resource.instance_of? RDFS::Resource)     
    #if a view was defined by the user.        
    
    if $USE_EXPLORATOR_VIEW && resource.explorator::view != nil && !is_class(resource)  
      resource.instance_eval(resource.explorator::view.to_s)          
      #render the resource type's view.
    elsif $USE_EXPLORATOR_VIEW && RDFS::Resource.new(resource.type[0].uri).explorator::view != nil 
      resource.instance_eval(RDFS::Resource.new(resource.type[0].uri).explorator::view)    
      #render a default property: label, name, title, or the resource localname
  else  
      session[:label_properties].each do |methodname| 
        #Do not use send here.
        value = eval ("resource." + methodname)
        if value != nil 
          return  truncate(value)
        end
      end      
      str = resource.uri.to_s.downcase
      str = str[str.length-4,str.length]
      if  str == '.jpg' || str =='.gif' || str =='.png'
          '<img class = "image"   src ="' + resource.uri + '"/>'
      else
        truncate(resource.localname)
      end        
      
    end    
  end 
end
