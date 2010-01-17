module CounterWithConditions
  # @param association_id extended belongs_to association
  # @param counter_name name of counter cache column
  # @param conditions hash with equal conditions, like {:read => false, :source => 'message'}, no nesting
  def counter_with_conditions(association_id, counter_name, conditions)
    unless is_a? InstanceMethods
      include InstanceMethods
      before_create :counter_with_conditions_after_create
      before_create :counter_with_conditions_before_destroy
      
      cattr_accessor :counter_with_conditions_options
      self.counter_with_conditions_options = []
    end
    self.counter_with_conditions_options << [association_id, counter_name, conditions]
  end

  module InstanceMethods
    private
    def counter_with_conditions_after_create
      
    end
    def counter_with_conditions_before_destroy
      
    end
    def counter_conditions_match?(conditions)
      conditions.all? do |attr, value|
        send(attr) == value
      end
    end
  end
end
