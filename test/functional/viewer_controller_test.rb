require File.dirname(__FILE__) + '/../test_helper'
require 'viewer_controller'
class ViewerControllerTest < ActionController::TestCase
 def setup
    @controller = ViewerController.new
    @request, @response = ActionController::TestRequest.new, ActionController::TestResponse.new
  end    
#test list all adapters.
  def test_index  
    set = ResourceSet.new('SemanticExpression.new().spo(\'<http://www.w3.org/2000/01/rdf-schema#Class>\',\'<http://www.w3.org/1999/02/22-rdf-syntax-ns#type>\',\'<http://www.w3.org/2000/01/rdf-schema#Class>\')') 
    post :index , :setid => set.rsid
    assert_response :success
    assert_not_nil assigns["view"]    
  end    
#test enable an adapter
  def test_setviewer      
    set = ResourceSet.new('SemanticExpression.new().spo(\'<http://www.w3.org/2000/01/rdf-schema#Class>\',\'<http://www.w3.org/1999/02/22-rdf-syntax-ns#type>\',\'<http://www.w3.org/2000/01/rdf-schema#Class>\')') 
    value ='self.localname'
    post :setviewer, :setid => set.rsid, :value => value  #do the request passing the adapter's object_id        
    resource =  set.resources[0]   
    assert_equal     resource.explorator::view, value   #assert that the view  was set.
    assert_response :success #assert that the request was executed successful
 end    
end
