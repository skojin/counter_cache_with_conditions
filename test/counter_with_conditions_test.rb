require File.dirname(__FILE__) + '/test_helper.rb'

class CounterWithConditionsTest < Test::Unit::TestCase 
  load_schema
  
  class Folder < ActiveRecord::Base
    has_many :messages
  end

  class Message < ActiveRecord::Base
    belongs_to :folder, :counter_cache => true
    counter_with_conditions :folder, :unread_messages_count, :unread => true
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
    f, m = build_fixture
    assert_equal 1, f.reload.messages_count
  end

  def test_default_counter_cache_should_decrement_on_destroy
    f, m = build_fixture
    assert_equal 1, f.reload.messages_count
    m.destroy
    assert_equal 0, f.reload.messages_count
  end

  # !!!!!
  def fail_test_default_counter_cache_not_update_counters_when_change_association_but_not_save
    f1, m = build_fixture
    assert_equal 1, f1.reload.messages_count
    f2 = Folder.create
    assert_equal 0, f2.reload.messages_count
    m.folder = f2
    assert_equal f1, m.reload.folder, "folder not changed"
    assert_equal 1, f1.reload.messages_count
    assert_equal 0, f2.reload.messages_count
  end

  # !!!!!
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

  # custom counter tests

  def test_should_increment_counter_on_create_when_condition_match
    f, m = build_fixture(:unread => true)
    assert_equal 1, f.reload.unread_messages_count
  end

  def test_should_not_increment_counter_on_create_when_condition_not_match
    f, m = build_fixture(:unread => false)
    assert_equal 0, f.reload.unread_messages_count
  end

  def test_should_decrement_counter_on_destroy_when_condition_match
    f, m = build_fixture(:unread => true)
    m.destroy
    assert_equal 0, f.reload.unread_messages_count
  end

  def test_should_not_decrement_counter_on_destroy_when_condition_not_match
    f, m = build_fixture(:unread => false)
    m.destroy
    assert_equal 0, f.reload.unread_messages_count
  end

  def test_should_decrement_counter_when_unread_unset_just_before_destroy
    f, m = build_fixture(:unread => true)
    m.unread = false
    m.destroy
    assert_equal 0, f.reload.unread_messages_count
  end

  def test_should_not_decrement_counter_when_unread_set_just_before_destroy
    f, m = build_fixture(:unread => false)
    m.unread = true
    m.destroy
    assert_equal 0, f.reload.unread_messages_count
  end

  def test_should_increment_counter_when_unread_set_on_update
    f, m = build_fixture(:unread => false)
    assert_equal 0, f.reload.unread_messages_count
    m.update_attribute :unread, true
    assert_equal 1, f.reload.unread_messages_count
  end

  def test_should_decrement_counter_when_unread_unset_on_update
    f, m = build_fixture(:unread => true)
    m.unread = false
    m.save!
    assert_equal 0, f.reload.unread_messages_count

    f, m = build_fixture(:unread => true)
    m.unread = true
    m.save!
    assert_equal 1, f.reload.unread_messages_count
  end

  def test_should_not_change_counter_when_unread_set_to_same_value_on_update
    f, m = build_fixture(:unread => true)
    assert_equal 1, f.reload.unread_messages_count
    m.unread = true
    m.save!
    assert_equal 1, f.reload.unread_messages_count
  end

  def test_should_change_counter_when_unset_folder_for_unread
    f, m = build_fixture(:unread => true)
    m.folder = nil
    m.save!
    assert_equal 0, f.reload.unread_messages_count
  end
  
  def test_should_change_counter_when_unset_folder_id_for_unread
    f, m = build_fixture(:unread => true)
    m.folder_id = nil
    m.save!
    assert_equal 0, f.reload.unread_messages_count
  end  

  def test_should_change_counter_when_unset_folder_and_unset_unread
    f, m = build_fixture(:unread => true)
    m.folder = nil
    m.unread = false
    m.save!
    assert_equal 0, f.reload.unread_messages_count
  end  

  def test_should_not_change_counter_when_unset_folder_id_for_read
    f, m = build_fixture(:unread => false)
    m.folder_id = nil
    m.save!
    assert_equal 0, f.reload.unread_messages_count
  end  

  def test_should_not_change_counter_when_unset_folder_set_unread
    f, m = build_fixture(:unread => false)
    m.folder = nil
    m.unread = true
    m.save!
    assert_equal 0, f.reload.unread_messages_count
  end  

  
  # TODO change folder, create with nil folder then assign it, change folder and change unread

  private
  def build_fixture(attributes = {})
    f = Folder.create
    m = f.messages.create attributes    
    [f, m]
  end

end

