require File.dirname(__FILE__) + '/../test_helper'

class RepositoryTest < Test::Unit::TestCase
 def setup    
  end
  def teardown    
  end
  def test_repository
    assert Repository.new(212,'teste',true).instance_of?(Repository)
    assert Repository.new(212,'teste',false).instance_of?(Repository)
  end
end
