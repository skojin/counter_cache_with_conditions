ActiveRecord::Schema.define do

  create_table "folders", :force => true do |t|
    t.integer  "messages_count", :null => false, :default => 0
    t.integer  "unread_messages_count", :null => false, :default => 0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "messages", :force => true do |t|
    t.belongs_to :folder
    t.boolean  "unread", :null => false, :default => true
  end

end
