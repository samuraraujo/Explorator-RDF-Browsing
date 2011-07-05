require File.dirname(__FILE__) + '/../test_helper'

class SetsPoolTest < Test::Unit::TestCase
  # Replace this with your real tests.
  #test remove the set from the pool
  def test_remove          
    a = ResourceSet.new('SemanticExpression.new')#create a set of resources    
    assert  Application.is_set?(a.rsid)  # asserts whether the new resourceset was added to the pool.
    Application.remove(a.rsid)  #removes the set of resource
    assert Application.is_set?(a.rsid)  # asserts whether the new resourceset was remove to the pool.
  end
  #test adding a set of resources to the pool
  def test_add          
    a = ResourceSet.new('SemanticExpression.new')#create a set of resources and add it to the pool    
    assert  Application.is_set?(a.rsid)  # asserts whether the new resourceset was added to the pool.    
  end
  #test whether the set could be return from the pool
  def test_get         
    a = ResourceSet.new('SemanticExpression.new')#create a set of resources and add it to the pool    
    assert_equal  Application.get(a.rsid), a  # asserts whether the new resourceset was added to the pool.    
  end
end
