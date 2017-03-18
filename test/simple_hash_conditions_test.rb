require File.dirname(__FILE__) + '/test_helper'


class SimpleHashConditionsTest < ActiveSupport::TestCase
  load_schema
  class Folder < ActiveRecord::Base
    has_many :messages
  end

  class Message < ActiveRecord::Base
    belongs_to :folder, :counter_cache => true
    counter_cache_with_conditions :folder, :unread_messages_count, :unread => true
  end
  
  def teardown
    Message.delete_all
    Folder.delete_all
  end

  eval IO.read(File.dirname(__FILE__) + '/unread_messages_count_tests.rb')

end

