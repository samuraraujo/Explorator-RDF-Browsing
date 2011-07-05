require "test/unit"
require File.dirname(__FILE__) + '/../test_helper'

class SemanticExpressionTest  <  Test::Unit::TestCase  
  #test the creating intansce.
  def test_create    
    assert SemanticExpression.new
  end
  #
  def test_union_with_empty_set    
    ##   @class = RDFS::Resource.new("<http://www.w3.org/2002/07/owl#Class>")
    s = '<http://www.w3.org/2000/01/rdf-schema#Class>'
    p = '<http://www.w3.org/1999/02/22-rdf-syntax-ns#type>'
    o = '<http://www.w3.org/2000/01/rdf-schema#Class>'
    
    [:s,:p,:o].each do |r|
      assert SemanticExpression.new().union(:s,:p, :o,r).result.size > 0
      assert SemanticExpression.new().union(s,:p, :o,r).result.size > 0
      assert SemanticExpression.new().union(:s,p, :o,r).result.size > 0
      assert SemanticExpression.new().union(:s,:p, o,r).result.size > 0
      assert SemanticExpression.new().union(s,:p, o,r).result.size > 0
      assert SemanticExpression.new().union(:s,p, o,r).result.size > 0
      assert SemanticExpression.new().union(s,p, :o,r).result.size > 0    
      assert SemanticExpression.new().union(s,p, o,r).result.size > 0
    end   
  end
  def test_intersection_with_empty_set    
    ##   @class = RDFS::Resource.new("<http://www.w3.org/2002/07/owl#Class>")
    s = '<http://www.w3.org/2000/01/rdf-schema#Class>'
    p = '<http://www.w3.org/1999/02/22-rdf-syntax-ns#type>'
    o = '<http://www.w3.org/2000/01/rdf-schema#Class>'
    
    [:s,:p,:o].each do |r|
      assert SemanticExpression.new().intersection(:s,:p, :o,r).result.size == 0
      assert SemanticExpression.new().intersection(s,:p, :o,r).result.size == 0
      assert SemanticExpression.new().intersection(:s,p, :o,r).result.size == 0
      assert SemanticExpression.new().intersection(:s,:p, o,r).result.size == 0
      assert SemanticExpression.new().intersection(s,:p, o,r).result.size == 0
      assert SemanticExpression.new().intersection(:s,p, o,r).result.size == 0
      assert SemanticExpression.new().intersection(s,p, :o,r).result.size == 0    
      assert SemanticExpression.new().intersection(s,p, o,r).result.size == 0
    end   
  end
  def test_diference_with_empty_set    
    ##   @class = RDFS::Resource.new("<http://www.w3.org/2002/07/owl#Class>")
    s = '<http://www.w3.org/2000/01/rdf-schema#Class>'
    p = '<http://www.w3.org/1999/02/22-rdf-syntax-ns#type>'
    o = '<http://www.w3.org/2000/01/rdf-schema#Class>'
    
    [:s,:p,:o].each do |r|
      assert SemanticExpression.new().difference(:s,:p, :o,r).result.size == 0
      assert SemanticExpression.new().difference(s,:p, :o,r).result.size == 0
      assert SemanticExpression.new().difference(:s,p, :o,r).result.size == 0
      assert SemanticExpression.new().difference(:s,:p, o,r).result.size == 0
      assert SemanticExpression.new().difference(s,:p, o,r).result.size == 0
      assert SemanticExpression.new().difference(:s,p, o,r).result.size == 0
      assert SemanticExpression.new().difference(s,p, :o,r).result.size == 0    
      assert SemanticExpression.new().difference(s,p, o,r).result.size == 0
    end   
  end
  def test_spo_with_empty_set    
    ##   @class = RDFS::Resource.new("<http://www.w3.org/2002/07/owl#Class>")
    s = '<http://www.w3.org/2000/01/rdf-schema#Class>'
    p = '<http://www.w3.org/1999/02/22-rdf-syntax-ns#type>'
    o = '<http://www.w3.org/2000/01/rdf-schema#Class>'
    
    [:s,:p,:o].each do |r|
      assert SemanticExpression.new().spo(:s,:p, :o,r).result.size > 0
      assert SemanticExpression.new().spo(s,:p, :o,r).result.size > 0
      assert SemanticExpression.new().spo(:s,p, :o,r).result.size >0  
      assert SemanticExpression.new().spo(:s,:p, o,r).result.size > 0
      assert SemanticExpression.new().spo(s,:p, o,r).result.size > 0
      assert SemanticExpression.new().spo(:s,p, o,r).result.size > 0
      assert SemanticExpression.new().spo(s,p, :o,r).result.size > 0    
      assert SemanticExpression.new().spo(s,p, o,r).result.size == 1
    end   
  end
  #Test the DSL's keyword method
  def test_keyword_with_empty_set    
    assert SemanticExpression.new().keyword('class').result.size > 0   
   assert SemanticExpression.new().keyword(nil).result.size >= 0   
  end
  #Test the QueryBuilder's isLiteral method
  def test_is_literal  
    assert SemanticExpression.new().isLiteral(:s) == false
    assert SemanticExpression.new().isLiteral(nil) == false
    assert SemanticExpression.new().isLiteral('') == true
    assert SemanticExpression.new().isLiteral("fdsfds") == true
    assert SemanticExpression.new().isLiteral(RDFS::Resource.new("<http://www.w3.org/2002/07/owl#Class>")) == false
  end
  #Test the QueryBuilder's to_resource method
   def test_to_resource 
    assert SemanticExpression.new().to_resource(:s,:s).instance_of?(Symbol)
    assert SemanticExpression.new().to_resource(nil,:s).instance_of?(Symbol)
    assert SemanticExpression.new().to_resource('',:s).instance_of?(String)
    assert SemanticExpression.new().to_resource("fdsfds",:s).instance_of?(String)
    assert SemanticExpression.new().to_resource(RDFS::Resource.new("<http://www.w3.org/2002/07/owl#Class>"),:s).instance_of?(RDFS::Resource)
  end
end
