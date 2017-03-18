require File.dirname(__FILE__) + '/test_helper'


class ComplexHashConditionsTest < ActiveSupport::TestCase
  load_schema
  
  class Folder < ActiveRecord::Base
    has_many :messages
  end

  class Message < ActiveRecord::Base
    belongs_to :folder, :counter_cache => true
  end

  class MessageClickedAt < Message
    counter_cache :folder, :clicked_messages_count, :clicked_at => true
  end
  class MessageMulti < Message
    counter_cache :folder, :unread_messages_count, :unread => true, :status => 'active'
  end
  class MessageTwoCounter < Message
    counter_cache :folder, :unread_messages_count, :unread => true
    counter_cache :folder, :clicked_messages_count, :clicked_at => true
  end

  def test_created_at_on_to_off
    f, m = build_fixture(MessageClickedAt, :clicked_at => Time.now)
    assert_equal 1, f.reload.clicked_messages_count, "should increment on create"
    m.update_attribute :clicked_at, nil
    assert_equal 0, f.reload.clicked_messages_count, "should decrement on update unset"
  end

  def test_created_at_off_to_on
    f, m = build_fixture(MessageClickedAt, :clicked_at => nil)
    assert_equal 0, f.reload.clicked_messages_count, 'no increment since off'
    m.update_attribute :clicked_at, Time.now
    assert_equal 1, f.reload.clicked_messages_count, "should increment on update when true"
  end

  
  def test_multi_on_to_off
    f, m = build_fixture(MessageMulti, :unread => true, :status => 'active')
    assert_equal 1, f.reload.unread_messages_count, "should increment on create"
    m.update_attribute :status, 'archived'
    assert_equal 0, f.reload.unread_messages_count, "should decrement on update when condition not match"
  end

  def test_multi_off_to_on
    f, m = build_fixture(MessageMulti)
    assert_equal 0, f.reload.unread_messages_count, "no increment since off"
    m.update_attribute :unread, true
    assert_equal 0, f.reload.unread_messages_count, "no increment since off"
    m.update_attribute :status, 'active'
    assert_equal 1, f.reload.unread_messages_count, "should increment on update when all conditions match"
  end

  def test_two_counters_create
    f, m = build_fixture(MessageTwoCounter, :unread => true, :clicked_at => Time.now)
    assert_equal 1, f.reload.unread_messages_count, "should increment on create"
    assert_equal 1, f.reload.clicked_messages_count, "should increment on create"
  end

  def test_two_counters_off_to_on
    f, m = build_fixture(MessageTwoCounter)
    assert_equal 0, f.reload.unread_messages_count, "no increment since off"
    assert_equal 0, f.reload.clicked_messages_count, "no increment since off"

    m.update_attributes :unread => true, :clicked_at => Time.now
    assert_equal 1, f.reload.unread_messages_count, "should increment on update since match"
    assert_equal 1, f.reload.clicked_messages_count, "should increment on update since match"
  end

  def teardown
    Message.delete_all
    Folder.delete_all
  end

  private
  def build_fixture(message_class, attributes = {})
    f = Folder.create
    m = message_class.new(folder: f)
    m.attributes = attributes
    m.save!
    [f, m]
  end

end

