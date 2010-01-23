module CounterWithConditions
  # @param association_id extended belongs_to association
  # @param counter_name name of counter cache column
  # @param conditions hash with equal conditions, like {:read => false, :source => 'message'}, no nesting
  def counter_with_conditions(association_id, counter_name, conditions)
    unless is_a? InstanceMethods
      include InstanceMethods
      after_create :counter_with_conditions_after_create
      before_update :counter_with_conditions_before_update
      before_destroy :counter_with_conditions_before_destroy
      
      cattr_accessor :counter_with_conditions_options
      self.counter_with_conditions_options = []
    end
    # TODO make readonly
    self.counter_with_conditions_options << [association_id, counter_name, conditions]
  end

  module InstanceMethods
    private
    def counter_with_conditions_after_create
      self.counter_with_conditions_options.each do |association_id, counter_name, conditions|
        if counter_conditions_match?(conditions)
          association = send(association_id)
          association.class.increment_counter(counter_name, association.id) unless association.nil?
        end
      end
    end
    
    def counter_with_conditions_before_update
      self.counter_with_conditions_options.each do |association_id, counter_name, conditions|
        association = send(association_id)
        next unless association

        match_before = counter_conditions_without_changes_match?(conditions)
        match_now = counter_conditions_match?(conditions)
        if match_now && !match_before
          association.class.increment_counter(counter_name, association.id)
        elsif !match_now && match_before
          association.class.decrement_counter(counter_name, association.id)
        end
      end
    end
    
    def counter_with_conditions_before_destroy
      self.counter_with_conditions_options.each do |association_id, counter_name, conditions|
        if counter_conditions_without_changes_match?(conditions)
          association = send(association_id)
          association.class.decrement_counter(counter_name, association.id) unless association.nil?
        end
      end
    end
    def counter_conditions_match?(conditions)
      conditions.all? do |attr, value|
        send(attr) == value
      end
    end
    def counter_conditions_without_changes_match?(conditions)
      conditions.all? do |attr, value|
        attribute_was(attr.to_s) == value
      end
    end
  end
end
