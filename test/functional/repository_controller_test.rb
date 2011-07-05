require File.dirname(__FILE__) + '/../test_helper'
require 'repository_controller'
class RepositoryControllerTest < ActionController::TestCase
  def setup
    @controller = RepositoryController.new
    @request, @response = ActionController::TestRequest.new, ActionController::TestResponse.new
  end 
#test list all adapters.
  def test_index    
    post :index 
    assert_response :success
    assert_not_nil assigns["repositories"]
    assert assigns["repositories"].size > 0
  end
  
  
#test enable an adapter
  def test_enable    
    #gets an adapter in the pool and disable it.
    anyadapter = ConnectionPool.adapters()[0] #gets an adapter
    anyadapter.enabled=false #disable it
    
    post :enable, {:id => anyadapter.object_id} #do the request passing the adapter's object_id
    
    afteradapter = ConnectionPool.adapters()[0] 
    assert_equal afteradapter.object_id, anyadapter.object_id #assert that the adapter is the same
    assert_response :success #assert that the request was executed successful
    assert afteradapter.enabled?  #asserts that the adapter  was shifted  to disabled
  end
    
#test disable an adapter
  def test_disable    
    #gets an adapter in the pool and disable it.
    anyadapter = ConnectionPool.adapters()[0]#gets an adapter
    anyadapter.enabled=true#sets the adapter for true
    
    post :disable, {:id => anyadapter.object_id} #do the request passing the adapter's object_id
    
    afteradapter = ConnectionPool.adapters()[0] #gets the same adapter again
    assert_equal afteradapter.object_id, anyadapter.object_id #assert that the adapter is the same
    assert_response :success #assert that the request was executed successful
    assert !afteradapter.enabled? #asserts that the adapter  was shifted  to disabled
  end
end
