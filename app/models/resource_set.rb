#This class represent a domain class where the resources are stored when 
#operated by the interface.
#You can treat this class as a set where his elements are define by the
#expression @expresion.
#Author: Samur Araujo
#Date: 25 jun 2008. 

class EXPLORATOR::Set < RDFS::Resource
   include RenderHelper
  self.class_uri = RDFS::Resource.new('http://www.tecweb.inf.puc-rio.br/ontologies/2008/explorator/01/core#Set')   
  #:name - #an word character(in ascii code) that names the set.
  #:rsid - resourceset id
  #:expresion - a SemanticExpression instance.
  #:resources - a array of RDFS::Resources
  #:offset - used to paginate the set
  #:pagination - the number of itens that a page should have.
  attr_accessor  :resources  
  #The constructor
  #receive as parameter a SemanticExpression instance.
  #'http://www.tecweb.inf.puc-rio.br/explorator/id/' + @rsid
  def initialize(uri)
    super(uri)          
    @elements = Array.new   
    if self.explorator::expression != nil            
      #enable only the repositories necessary to perform the expression eval.
      #setup_repositories()
      self.expression=self.explorator::expression 
    end
    self.save
  end
  def init(exp) 
    $contextindex = 65 if $contextindex == nil
    self.explorator::pagination=30
    self.explorator::offset = 1
    
    #naming the set  
    self.explorator::name='SET ' + $contextindex.chr 
    #The set is named automacally, so a counter should be incremented here.
    $contextindex +=1
    #Reset the counter when the name reach the 'Z' letter (90 in ASCII). 
    $contextindex = 65 if $contextindex > 90
    #add this set to the pool.
    self.expression=exp
    Thread.current[:application].add(self);
  end 
  #Returns an array of resources.
  def resources    
    return @elements.collect{|s,p,o| s}.compact.uniq  
  end
  def elements
    if @elements == nil
      Array.new
    else
          return @elements
    end

    
  end
  #setup repositories
  def setup_repositories
    r = self.explorator::repository    
    r.each do |x|      
      Repository.enable_by_title(x)
    end
  end
  def set_repositories
    #set the current repositories enable when the query was evaluated
    r =  ConnectionPool.read_adapters.collect{|x| x.title}    
    self.explorator::repository=r
  end
  #defines a new expression and reevaluates the expression.
  def expression=(exp)  
    puts '## Evaluating Expression ##'
    puts exp
   # begin           
      #for avoid loop evaluation.
      current_expression = self.explorator::expression
 
      exp.gsub!("'" + self.to_s + "'",current_expression) if  current_expression != nil
      #evaluates the expression      
      x = eval(exp)     
#      updates the expression
      self.explorator::expression = exp.to_s 
      #  set_repositories()
   # rescue      
      #whether the expression is invalid.
  #    raise ExploratorError.new('Expression could not be evaluated')
  #  end    
    #whether the expression is not a SemanticExpresion instance.
    raise ExploratorError.new('The expression must be a SemanticExpression instance') if !x.instance_of? SemanticExpression
    #return a sorted array of RDFS::Resources 
    @elements = x.result.compact
    
        

    #try to sort the array as a array of numbers
#    begin
#      #@resources.sort!{|a,b|a.to_f<=>b.to_f}
#      @resources.sort!()
#    rescue      
#      puts 'ERRO SORTING'
#      #whether the expression is invalid.      
#    end    
    
     #@resources=sorting_resource(@resources)
    @elements
  end
  def sorting_resource(resources)
    sorted = Hash.new    
    resources.each {|r|       
      sorted[r] = render_resource(r)      
    }     
    y=sorted.sort{|a,b| a[1]<=>b[1]}     
    y.collect{|x|  x[0]}
  end
  #defined the offset. this will be used for paginated the access to all resources.
  def setWithOffset(offset)          
    if offset != nil
      self.explorator::offset = offset
    end
    self
  end
#  def addFilter(filter)
#    self.expression=self.explorator::expression + '.'+ filter
#  end
#  def sum
#    self.expression=self.explorator::expression + '.'+  "filter('inject( 0 ) { |sum,x| sum+x.to_i } ')"
#    
#  end
end
