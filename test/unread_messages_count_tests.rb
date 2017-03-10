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

  # custom counter tests

  def test_should_increment_counter_on_create_when_condition_match
    f, _ = build_fixture(:unread => true)
    assert_equal 1, f.reload.unread_messages_count
  end

  def test_should_not_increment_counter_on_create_when_condition_not_match
    f, _ = build_fixture(:unread => false)
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

  # ---------- when association nillified ------------

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

  # ---------- when association changed ------------

  def test_should_not_change_counters_when_change_folder_for_read
    f, m = build_fixture(:unread => false)
    f2  = Folder.create!
    m.folder = f2
    m.save!
    assert_equal 0, f.reload.unread_messages_count
    assert_equal 0, f2.reload.unread_messages_count
  end
  
  def test_should_change_counter_when_change_folder_for_unread
    f, m = build_fixture(:unread => true)
    f2  = Folder.create!
    m.folder = f2
    m.save!
    assert_equal 0, f.reload.unread_messages_count
    assert_equal 1, f2.reload.unread_messages_count
  end

  # this test is important, it fail in process
  def test_should_change_counter_on_old_and_skip_counter_on_new_when_change_folder_for_unread_with_status_change
    f, m = build_fixture(:unread => true)
    f2  = Folder.create!
    m.folder = f2
    m.unread = false
    m.save!
    assert_equal 0, f.reload.unread_messages_count
    assert_equal 0, f2.reload.unread_messages_count
  end
  
  def test_should_ignore_counter_on_old_and_icrement_counter_on_new_when_change_folder_for_read_with_status_change
    f, m = build_fixture(:unread => false)
    f2  = Folder.create!
    m.folder = f2
    m.unread = true
    m.save!
    assert_equal 0, f.reload.unread_messages_count
    assert_equal 1, f2.reload.unread_messages_count
  end
  
  # ---------- when association was nil ------------

  def test_should_icrement_counter_when_assing_folder_for_unread
    m = Message.create!(:unread => true)
    f = Folder.create!
    m.folder = f
    m.save!
    assert_equal 1, f.reload.unread_messages_count
  end
  
  def test_should_ignore_counter_when_assing_folder_for_read
    m = Message.create!(:unread => false)
    f = Folder.create!
    m.folder = f
    m.save!
    assert_equal 0, f.reload.unread_messages_count
  end
  
  def test_should_ignore_counter_when_assing_folder_for_unread_and_mark_as_read
    m = Message.create!(:unread => true)
    f = Folder.create!
    m.folder = f
    m.unread = false
    m.save!
    assert_equal 0, f.reload.unread_messages_count
  end
  
  def test_should_increment_counter_when_assing_folder_for_read_and_mark_as_unread
    m = Message.create!(:unread => false)
    f = Folder.create!
    m.folder = f
    m.unread = true
    m.save!
    assert_equal 1, f.reload.unread_messages_count
  end
  

  # ---------- when association changed before destroy ------------

  def test_should_decrement_counter_when_association_unset_just_before_destroy_when_match
    f, m = build_fixture(:unread => true)
    m.folder = nil
    m.destroy
    assert_equal 0, f.reload.unread_messages_count

    # just to be sure, dublicate test with attribute change
    f, m = build_fixture(:unread => true)
    m.folder = nil
    m.unread = false
    m.destroy
    assert_equal 0, f.reload.unread_messages_count
  end

  def test_should_not_decrement_counter_when_association_unset_just_before_destroy_when_not_match
    f, m = build_fixture(:unread => false)
    m.folder = nil
    m.unread = true
    m.destroy
    assert_equal 0, f.reload.unread_messages_count

    # just to be sure, dublicate test with attribute change
    f, m = build_fixture(:unread => false)
    m.folder = nil
    m.unread = true
    m.destroy
    assert_equal 0, f.reload.unread_messages_count
  end

  def test_should_decrement_counter_when_association_changed_just_before_destroy_when_match
    f, m = build_fixture(:unread => true)
    f2 = Folder.create!
    m.folder = f2
    m.destroy
    assert_equal 0, f.reload.unread_messages_count
    assert_equal 0, f2.reload.unread_messages_count
  end

  private
  def build_fixture(attributes = {})
    f = Folder.create
    m = f.messages.create attributes    
    [f, m]
  end
