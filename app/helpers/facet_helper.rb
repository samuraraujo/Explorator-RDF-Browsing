module FacetHelper  
  def term(resource)    
    resource.faceto::literalTerm == nil ? resource.faceto::derivedTerm : resource.faceto::literalTerm
  end 
end