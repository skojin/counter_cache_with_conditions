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
    counter_cache_with_conditions :folder, :clicked_messages_count, :clicked_at => true
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

  
  def teardown
    Message.delete_all
    Folder.delete_all
  end

  private
  def build_fixture(message_class, attributes = {})
    f = Folder.create
    m = MessageClickedAt.new(folder: f)
    m.attributes = attributes
    m.save!
    [f, m]
  end

end

