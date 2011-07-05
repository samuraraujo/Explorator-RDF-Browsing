require File.dirname(__FILE__) + '/../test_helper'
require 'viewer_controller'
class ExploratorControllerTest < ActionController::TestCase
 def setup
    @controller = ExploratorController.new
    @request, @response = ActionController::TestRequest.new, ActionController::TestResponse.new
  end    
#tests whether the index exist
  def test_index  
    post :index 
    assert_response :success     
  end    
#test execute method where a expression is passed as parameter
  def test_execute
    #Adds a set in the pool that will be removed later.
    set = ResourceSet.new('SemanticExpression.new().spo(\'<http://www.w3.org/2000/01/rdf-schema#Class>\',\'<http://www.w3.org/1999/02/22-rdf-syntax-ns#type>\',\'<http://www.w3.org/2000/01/rdf-schema#Class>\')') 
    #test refresh
    post :execute, :exp=> 'refresh(\'' +set.rsid+ '\')'
    assert    @controller.resourceset.resources.size > 0  #assert that set was remove
    assert_response :success #assert that the request was executed successful
    #test remove    
    post :execute, :exp=> 'remove(\'' +set.rsid+ '\')'
    assert    Application.is_set?(set.rsid)  #assert that set was remove
    assert_response :success #assert that the request was executed successful
 end    
 #test create method that creates a new ResourceSet based in the expression passed as parameter
  def test_create
    #create a new resourceset
    post :create, :exp=> 'SemanticExpression.new.union(:s,Namespace.lookup(:rdf,:type),Namespace.lookup(:rdfs,:Class))'
    assert    @controller.resourceset.resources.size > 0  #assert that set was remove
    assert_response :success #assert that the request was executed successful
   
 end   
 #test update method that updates a new ResourceSet based in the expression passed as parameter
  def test_update
    set = ResourceSet.new('SemanticExpression.new().spo(\'<http://www.w3.org/2000/01/rdf-schema#Class>\',\'<http://www.w3.org/1999/02/22-rdf-syntax-ns#type>\',\'<http://www.w3.org/2000/01/rdf-schema#Class>\')') 
    size = set.resources.size
    #create a new resourceset. Note that the expression must return more resource than the first one.
    #we will check the number of resources to verify whether the set was updated.
    post :update, :exp => 'SemanticExpression.new.union(:s,Namespace.lookup(:rdf,:type),:o)', :id => set.rsid
    assert    @controller.resourceset.resources.size > size  #assert that set was remove
    assert_response :success #assert that the request was executed successful
end   
end
