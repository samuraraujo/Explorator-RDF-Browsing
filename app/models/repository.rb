#The repository class represents a ActiveRDF repository. 
#This is a VO  used by the user interface.
#Author: Samur Araujo
#Date: 25 jun 2008.
class Repository  
  #name - the repository name
  #id - the repository id 
  #enable - a boolean value that indicates whether the repository is enable or disable.
  attr_accessor :title, :id, :enable,:limit
  #the class constructor. 
  def initialize(id,title,  enable,limit)   
    @id=id
    @title=title
    @enable=enable
    @limit=limit
  end  
  class << self
    
    def disable_all      
      #gets all adapters.
      adapters = ConnectionPool.adapters()
      #finds the adapter identified by the id parameter.
      adapters.each do |repository|                   
        FederationManager.enable(repository,false)
      end      
    end
    def disable_by_title(title)      
      #gets all adapters.
      adapters = ConnectionPool.adapters()
      #finds the adapter identified by the id parameter.
      adapters.each do |repository| 
        if repository.title == title
          #disable the adapter.
          FederationManager.enable(repository,false)
        end
      end       
    end
    
    def enable_by_title(title)
      #identifies the adapter.      
      #gets all adapters.
      adapters = ConnectionPool.adapters()
      #finds the adapter identified by the id parameter.
      adapters.each do |repository| 
        if repository.title == title
          #enable the adapter.
          FederationManager.enable(repository,true)
        end
      end       
    end
  end
end
