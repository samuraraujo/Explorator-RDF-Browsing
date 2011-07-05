#This Controller is in charge of the facet generation. 
#It implements a algorithms that uses entropy to determinate the weight of each facet.
#It algorithms is better described in the Explorator spefication.
#Author: Samur Araujo
#Date: 25 jun 2008.

#module where the SemanticExpression class is defined.
require 'query_builder'
#module where the query class is defined.
require 'query_factory'
class FacetsController < ApplicationController
  #session :disabled => true
  #The execute method  evaluate a ruby expression. 
  #this method is used to invoke another method of Explorator.
  #Basically, the UI call this method passing as the expression a 
  # call to the method facet or infer.
  def execute    
    eval(params[:exp])
  end  
  def create
    properties= eval(params[:exp]).result.collect{|s,p,o| s}.compact.uniq    
    facetgroup=FACETO::FacetGroup.new('<http://http://www.tecweb.inf.puc-rio.br/2008/faceto#' << params[:name] << '>')
    facetgroup.rdfs::label=params[:name]
    facetgroup.faceto::type=RDFS::Resource.new('http://www.tecweb.inf.puc-rio.br/2008/faceto#userdefined')
    facetgroup.save
    #it will hold all the facets
    facets = Array.new
    properties.each do |predicate|
      if predicate.instance_of? RDF::Property        
        # puts predicate
        #create a object FACETO:Facet for each resource property and add it to the facets array.
        #This code only creates facets that represents properties. Facets that represents expressions are not considerated here.
        id =UUID.random_create.to_s
        facet = FACETO::Facet.new('<http://www.tecweb.inf.puc-rio.br/2008/faceto#' << id << '>')
        facet.save              
        facet.faceto::derivedTerm = predicate      
        facet.faceto::use = predicate          
        facet.save     
        #add the facet to the facet array.
        facets << facet        
        #Sets the facets for the FacetGroup object.        
      end       
    end
    facetgroup.faceto::facet = facets  
    facetgroup.save
    render  :action=> 'create',:layout=>false;
  end  
  #the parameter id is the ResourceSet identification in the SetsPool.
  def facet (exp)  
    puts "$$$$$ 1"
    puts Query.new.adapters(ConnectionPool.get_adapter('INTERNAL')).sparql("SELECT DISTINCT ?s WHERE { ?s <http://www.w3.org/2000/01/rdf-schema#label> ?o1 FILTER(str(?o1) = 'dblpfacets2')").execute
    puts '$$$$$ 4'
    #gets a ResourceSet instance in the pool.
    set = session[:application].get(exp)    #the object @resourceset is a global object that will be used by render
    @resourceset = set     
    
    #Gets a facet defined by the user in the repository.
    # FACETO::FacetGroup belong to the ActiveRDF model and the vocabulary FACETO::FacetGroup was defined by the Explorator.
    
    #  @groups=FACETO::FacetGroup.find_all()
    #  @facetgroup=FACETO::FacetGroup.find_by_rdfs::label('Group1').first
    @groups=FACETO::FacetGroup.find_by_faceto::type(RDFS::Resource.new('http://www.tecweb.inf.puc-rio.br/2008/faceto#userdefined'))
    puts '###### 1'
    @facetgroup =nil
    @groups.each do |x|
      @facetgroup =x if x.label == params[:name]
      
    end 
    #Calculates all the facets for a set of resources.
    entropy_by_set(@resourceset.resources)
    #render the _facet.rhtml view
    render :partial => "facet" 
  end
  #Infer the facets for the specific set
  def infer   (exp)      
    #gets a ResourceSet instance in the pool.
    set = session[:application].get(exp)
    
    #the object @resourceset is a global object that will be used by render
    @resourceset = set     
    
    
    @groups=FACETO::FacetGroup.find_by_faceto::type(RDFS::Resource.new('http://www.tecweb.inf.puc-rio.br/2008/faceto#userdefined'))
    
    inference(@resourceset.resources,UUID.random_create.to_s)
    #Calculates all the facets for a set of resources
    entropy_by_set(@resourceset.resources)    
    #render the _facet.rhtml view
    render :partial => "facet" 
  end
  #The entropy_by_set method implements the facet algorithm itself.
  #The algorithm only calculates facets that are defined as resource properties.
  #Others kind of facets, described in the specification, are not taken into account here.
  # Calculates the entropy for each facet.
  def entropy_by_set(_resources) 
    puts 'FACETANDO...'
    #store the valid facets
    @facets_cardinalities = Hash.new
    @entropies = Hash.new
    @exp=Hash.new
    if _resources.size() ==0
      return
    end
    #detect using entropy wich facet will be valid
    if @facetgroup == nil
      return
    end        
    @facetgroup.all_faceto::facet.each do |facet|              
      #handles the facets that have an hierarchy of values.
      facetroot = facet.instance_eval("faceto::level1")
      puts '############CALCULATING ENTROPY FOR FACET ############'
      puts 'FACET NAME: ' + facet.faceto::derivedTerm.to_s
      if   facetroot  != nil 
        facet = facetroot 
      end
      #      if $already_selected  == nil 
      #      $already_selected= Array.new
      #      end
      #      if facetroot != nil    
      #        i=1
      #        while $already_selected.include?( facetroot )
      #          i+=1
      #          facetroot = facet.instance_eval("faceto::level" + i.to_s)
      #          puts 'teste'+ i.to_s
      #        end
      #        if facetroot == nil
      #          next  
      #        end 
      #        $already_selected << facetroot     
      #        facet = facetroot          
      #           
      #      end         
      #the synonym are used when the are 2 or more object properties that describe the same values.
      #See the definition bellow
      #      :country rdf:type faceto:Facet ;      
      #           faceto:derivedTerm fn:country;
      #           faceto:synonym   :brasil
      #           faceto:synonym   :america 
      #            faceto:use dp1:region
      #           faceto:operation 'union'      
      #    :brasil  faceto:word fn:region/bra; 
      #              faceto:word fn:region/brasil;    
      #
      #    :america faceto:word fn:region/americas; 
      #              faceto:word dp:country/americas.
      
      synonyms = Hash.new
      facet.all_faceto::synonym.each{|synonym|
        synonyms[synonym.all_word] = synonym
      }      
      entropy = 0
      objects = Array.new # all possible values for this facet
      @exp[facet]= Hash.new
      
      prob_p=0 # probability of occurency of this facet (or predicate) in this resource
      hash_object=Hash.new # objects occurency
      _resources.each do |resource|        
        next if !resource.instance_of? RDFS::Resource    
        qresult = Array.new
        type = 'normal' #use when there are computedvalue in the facet
        constraint=nil
        computedValue =  facet.all_faceto::computedValue           
        computedValue.each {|cvalue|              
          begin           
            type='computed' 
            #verifies if the computedvalue has a contraint expression
            if cvalue.faceto::constraint != nil
              #set the facet for the type contraint
              type='constraint'                
              #all contraint computedvalue has a query expression
              constraint=cvalue.faceto::query                                 
            end
            #verifies whether the resource satisfies the constraint(faceto::contraint) in case of exists.
            if  cvalue.faceto::constraint == nil  || resource.instance_eval(cvalue.faceto::constraint) == true              
              #the variable will be passed to the exp method to create the expression correctly              
              if cvalue.faceto::expressionValueLabel != nil 
                qresult <<  resource.instance_eval(cvalue.faceto::expressionValueLabel)
                #verifies if the computed value has a queryvalue expresion. This expression is used to get the facet values.
              elsif cvalue.faceto::queryValues != nil   
                #get the expression used to filter the elements being faceted
                constraint=cvalue.faceto::query    
                #get all possible values for the facet.
                qresult = qresult |  eval(cvalue.faceto::queryValues)                 
              else
                #get a literal value
                qresult <<  cvalue.faceto::literalValue                
              end
              break
            end
          rescue
            print "An error occurred: ",$!, "\n"
          end     
        }      
        puts '1 ----------------------------'
        puts resource
        #verifies if the facet is a derived type.
        if computedValue.size() == 0
          
          if facet.faceto::use != nil  
            #get the values based in the property
            #  qresult = QueryFactory.new.distinct(:o).where(resource, facet.faceto::use,:o).execute
            puts facet.faceto::use.localname
            # puts facet.faceto::use 
            
            qresult = resource.instance_eval(facet.faceto::use.localname)          
          elsif facet.faceto::useInverse != nil
            puts facet.faceto::use.localname 
            puts facet.faceto::use 
            
            # qresult = QueryFactory.new.distinct(:o).where(resource, facet.faceto::useInverse,:o).execute
            qresult = resource.instance_eval(facet.faceto::useInverse.localname)
          end    
        end
        if !qresult.instance_of? Array
          t = Array.new 
          t << qresult
          qresult = t
        end
        puts qresult
        puts '2 ----------------------------'
        #property :p occurs em :s
        if qresult.size > 0          
          prob_p += 1
        end
        
        #frequence that :o occurs for each :s
        qresult.each do |o|             
          #gets the default word in case where exists a table of synonyms   
          synomymswords =nil
          if synonyms.size() > 0
            synonyms.keys.each{|words|
              if words.include?(o)    
                synomymswords=words
                o =  synonyms[words].faceto::defaultWord
                break
              end
            }
          end
          if hash_object[o] == nil
            hash_object[o] = 1              
            #create the query expression for this facet values
            exp(facet, resource, o,type,synomymswords,constraint)              
          else
            hash_object[o] = hash_object[o]+1            
          end          
        end
      end
      
      # puts prob_p
      #calculates the object occurencies
      condition = hash_object.values.sort
      
      next if condition.first == 1 && condition.last ==1
      puts hash_object
      hash_object.each_key do |object|     
        count= hash_object[object]
        
        # puts object
        
        #calculate the object probability
        #puts prob_p.to_f
        #puts count
        prob_o = count.to_f / prob_p.to_f
        # puts prob_o
        if prob_o !=1          
          objects << object          
          #calculate the entropy based on the object probability
          entropy = entropy + prob_o * Math.log(prob_o)  / Math.log( 2 )  
        end       
      end       
      
      #calculates the objects' cardinality 
      
      if entropy != 0         
        cardinalities = Array.new       
        objects.each do |object|
          #  puts object
          h = Hash.new          
          h[object]=hash_object[object]
          cardinalities << h
        end                    
        f = FACETO::Facet.new(facet)
        puts 'entropy'
        puts entropy
        puts 'object size'
        puts hash_object.size
        puts 'max entropy'
        puts  max_entropy_for_n(hash_object.size)
        puts 'probability'
        puts prob_p
        @entropies[f]=[prob_p,normatize(max_entropy_for_n(hash_object.size),entropy)] #normatize entropy value to be used in the sort function
        puts @entropies[f]
        @facets_cardinalities[f]=cardinalities        
      end      
    end        
    @entropies = @entropies.to_a
    #sort the facets by property occurency and by maximum entropy        
    @entropies.sort!  do |a, b|
      r = b[1][0]<=>a[1][0]
      r = a[1][1]<=>b[1][1]  if r == 0
      r
    end   
  end
  #calculates the max entropy for  n probability values.
  def   max_entropy_for_n(n)
   (( 1 / n.to_f) * Math.log(( 1 / n.to_f))  )  * n.to_f / Math.log( 2 )
  end
  def   normatize(max,value)
    a = ((max * -1) - (value  * -1))
    if a >= 0
      a 
    else
      a * -1
    end
  end
  
  ####################################################################################
  #The inference method determines each possible facet, based on each resources properties
  #The algorithm used is basd on entropy concept.
  def inference(resources,cid)
    #all predicates from all resources passed as parameters
    predicates = Array.new    
    resources.each do |s|      
      predicates= predicates | s.all_instance_predicates
    end    
    
    #create a object FacetGroup for this instance of resources
    @facetgroup=FACETO::FacetGroup.new('<http://www.tecweb.inf.puc-rio.br/2008/faceto#' << cid << '>')
    @facetgroup.rdfs::label=cid
    @facetgroup.faceto::type=RDFS::Resource.new('http://www.tecweb.inf.puc-rio.br/2008/faceto#infered')
    @facetgroup.save
    #it will hold all the facets
    facets = Array.new
    #create an object FACETO:Facet for each resource property and add it to the facets array.
    #This code only creates facets that represents properties. Facets that represents expressions are not considerated here.
    predicates.each do |predicate|       
      facet = FACETO::FacetGroup.find_by_faceto::use(predicate).first()
      if facet == nil
        
        id =UUID.random_create.to_s
        facet = FACETO::Facet.new('<http://www.tecweb.inf.puc-rio.br/2008/faceto#' << id << '>')
        facet.save     
        facet.faceto::derivedTerm = predicate      
        facet.faceto::use = predicate    
        facet.save     
      end
      #add the facet to the facet array.
      facets << facet
    end 
    #Sets the facets for the FacetGroup object.
    @facetgroup.faceto::facet = facets    
  end  
  #create the expression for each facet value.
  #the expression is different for each facet value.
  def exp(facet, resource, value,type,words,constraint=nil,header=true,operation='intersection')          
    #it will store the expression
    exp = ''   
    #get the value for a specific property when the value was computed.     
    if type=='computed' && constraint != nil              
      exp= '(' + constraint.gsub('resource', "RDFS::Resource.new('"+value.to_s+"')")   + ',:p, :o)'
    elsif type=='constraint'    
      exp = @resourceset.expression + "."      
      #must be a filter expression
      exp = exp + constraint
      return  @exp[facet][value] =   exp
    else       
      properties = Array.new
      #gets all properties used to calculated the facet value
      properties = properties | facet.all_faceto::use
      #iterate over each property
      properties.each {|property|       
        if type=='computed'
          #gets the value of this property in this resource
          object  = Query.new.distinct(:o).where(resource,property,:o).execute.to_s
        else
          #the value in the interface is the same as than the value that will be in the expression
          #in this case the value was not computed but derived from a property.
          object = value.to_s
        end   
        if exp == ''
          exp = "(:s,'" + property.to_s() + "', '"+ object + "')"        
        else
          exp = exp + "."+operation+"(:s,'" + property.to_s() + "', '"+ object + "')"        
        end        
      }       
      properties = Array.new
      properties = properties | facet.all_faceto::useInverse
      #iterate over each property
      properties.each {|property|       
        if type=='computed'
          #gets the value of this property in this resource
          #         object=Query.new.distinct(:o).where(:o,property,resource).execute.to_s
          object = resource.instance_eval(property.localname)
        else
          #the value in the interface is the same as than the value that will be in the expression
          #in this case the value was not computed but derived from a property.
          object = value.to_s
        end   
        if exp == ''
          exp = "('"+ object + "','" + property.to_s() + "', :s)"    
        else
          exp = exp + "."+operation+"('"+ object + "','" + property.to_s() + "', :s)"        
        end        
      }          
    end
    if words != nil
      words.each {|word|
        if word!=value
          exp = exp + ".union"+ exp(facet, resource, word,type,nil,constraint,false) 
        end
      }
    end
    if header
      exp =  "SemanticExpression.new" + exp
    end
    puts exp
    @exp[facet][value] =   exp
  end
end
