require File.dirname(__FILE__) + '/test_helper.rb'

class ActiveRecordCounterCacheTest < Test::Unit::TestCase 
  load_schema
  
  class Folder < ActiveRecord::Base
    has_many :messages
  end

  class Message < ActiveRecord::Base
    # uncomment this, and comment out lines below, too see active record counter cache error
    #belongs_to :folder, :counter_cache => true
    
    belongs_to :folder
    counter_cache_with_conditions :folder, :messages_count, {}
  end

  def teardown
    Message.delete_all
    Folder.delete_all
  end
 
  def test_schema_has_loaded_correctly
    assert_equal [], Folder.all
    assert_equal [], Message.all
  end

  # default rails counter tests
  def test_default_counter_cache_should_increment_on_create
    f, _ = build_fixture
    assert_equal 1, f.reload.messages_count
  end

  def test_default_counter_cache_should_decrement_on_destroy
    f, m = build_fixture
    assert_equal 1, f.reload.messages_count
    m.destroy
    assert_equal 0, f.reload.messages_count
  end

  # active record counter cache fail on this
  def test_default_counter_cache_not_update_counters_when_change_association_but_not_save
    f1, m = build_fixture
    assert_equal 1, f1.reload.messages_count
    f2 = Folder.create
    assert_equal 0, f2.reload.messages_count
    m.folder = f2
    assert_equal f1, m.reload.folder, "folder not changed"
    assert_equal 1, f1.reload.messages_count
    assert_equal 0, f2.reload.messages_count
  end

  # active record counter cache fail on this
  def fail_test_default_counter_cache_update_counters_when_change_association_via_id
    f1, m = build_fixture
    assert_equal 1, f1.reload.messages_count
    f2 = Folder.create
    assert_equal 0, f2.reload.messages_count
    m.folder_id = f2.id
    m.save
    assert_equal 0, f1.reload.messages_count
    assert_equal 1, f2.reload.messages_count
  end

  private
  def build_fixture(attributes = {})
    f = Folder.create
    m = f.messages.create attributes    
    [f, m]
  end

end

