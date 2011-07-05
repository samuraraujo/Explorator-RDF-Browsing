require File.dirname(__FILE__) + '/../test_helper'

class ResourceSetTest <   Test::Unit::TestCase
  
  def setup
    
  end
  def teardown
    
  end
  # Test whether the ResourceSet was instanciated
  def test_create          
    a = ResourceSet.new('SemanticExpression.new') 
    assert_not_nil a.resources # asserts whether the new resourceset was added to the pool.
    assert Application.is_set?(a.rsid) # asserts whether the new resourceset was added to the pool.
     
    assert_raises (ExploratorError){ ResourceSet.new('')}
    assert_raises (ExploratorError){ ResourceSet.new('SemanticExpression.new(2)') }    
    assert_raises (ExploratorError){ ResourceSet.new(nil)}
    
  end
   # Test whether the setexpression method
   def test_expression          
    a = ResourceSet.new('SemanticExpression.new')     
    assert_raises (ExploratorError){ a.expression = ''}
    assert_raises (ExploratorError){ a.expression ='SemanticExpression.new(2)' }    
    assert_raises (ExploratorError){ a.expression = nil}    
  end
 
end
