#The Explorator Helper has several methods used by the files.rhtml.
#Basically, Its methods help the view to hender a RDFS::Resource.
#Author: Samur Araujo
#Date: 25 jun 2008.
module ExploratorHelper
  include RenderHelper
  #Returns a resourceset define in the controllers.  
  def get_resources(type=:s)
    groupBy(type)      
  end
  def resourceset     
    @resourceset
  end 
  #return an interval of resources from the offset to the pagination attribute.
  #This method is used when the user is paginating a set of resources
  def groupBy (type=:s)   
   
    @resourceset.elements.collect{|s,p,o| eval(type.to_s)}.compact.uniq   
  end
  def resources_paginated(type=:s)      
    resources=  groupBy(type) 
    
    @size =  resources.size()
    if((@filter!=nil)&&(@filter!=""))
      resources =   resources.select {|x|         
        render_resource(x).to_s().downcase.index(@filter.downcase) != nil
      }
      @size = resources.size()
      return resources
    end    
    
    #    resources = resources[@resourceset.offset.to_i,@resourceset.pagination.to_i]
    
    
    resources = resources.paginate(:page=>@resourceset.offset.to_i,:per_page =>$WILL_PAGINATE_PER_PAGE)
    resources
  end
  
  
  def subjects(predicate, resource=nil)
    @resourceset.elements.collect{|s,p,o| s if  (resource == o || resource == nil) && predicate == p}.compact.uniq    
  end
  def predicates(resource,type=:s)    
    @resourceset.elements.collect{|s,p,o| p if resource == eval(type.to_s)}.compact.uniq    
  end
  def objects(resource,predicate)
    @resourceset.elements.collect{|s,p,o| o if  resource == s && predicate == p}.compact.uniq
  end  
  #Return a resource set expression. 
  def get_expression       
    @resourceset.explorator::expression
  end 
  #return the uri as a string
  def to_s(resource)     
    return resource if (resource.instance_of? String)    
    return resource.uri if (resource.instance_of? RDFS::Resource) 
  end
  #Resource URI
  def uri (resource)  
    return resource.to_s.gsub("'","\\\\'")  if  (resource.instance_of? RDFS::Literal)    
    return resource.gsub("'","\\\\'")  if  (resource.instance_of? String)   
    
    return resource 
  end
  #this will be added in the class attribute of the html element.
  #return a string of all resource types separated by space.
  def css(resource)        
    if resource.instance_of? String
      return ' resource string'
    end  
    if resource.instance_of? BNode
      return ' resource '
    end         
    classes = Array.new      
    
    resource.type.each do |type|      
      classes <<   type.localname.downcase     
    end    
    classes.uniq.join(' ') << ' '    
  end
  #verifies whether the resource is from type class.
  def is_class(resource)
    if resource.instance_of? String
      return false
    end    
    resource.type.each do |type|
      if type.localname.downcase == 'class'
        return true
      end

    end
    return false
  end  
end
