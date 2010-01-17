require File.dirname(__FILE__) + '/test_helper.rb'

class CounterWithConditionsTest < Test::Unit::TestCase 
  load_schema
  
  class Folder < ActiveRecord::Base
  end

  class Message < ActiveRecord::Base
    belongs_to :folder, :counter_cache => true
  end


  def test_schema_has_loaded_correctly
    assert_equal [], Folder.all
    assert_equal [], Message.all
  end

end

