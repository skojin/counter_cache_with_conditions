module CounterCacheWithConditions
  module ActiveRecord

    # @param association_name extended belongs_to association name (like :user)
    # @param counter_name name of counter cache column
    # @param conditions hash with equal conditions, like {:read => true, :source => 'message'}, no nesting
    # @param block proc object that take list of arguments specified in conditions parameter, should compare them and return boolean
    #                   usage looks like lambda{|read, source| read == true && source == 'message'}
    #                   lambda parameter should match to this record attributes that need to check for change
    def counter_cache_with_conditions(association_name, counter_name, conditions = {}, block = nil)
      unless ancestors.include? InstanceMethods
        include InstanceMethods
        after_create :counter_cache_with_conditions_after_create
        before_update :counter_cache_with_conditions_before_update
        before_destroy :counter_cache_with_conditions_before_destroy

        cattr_accessor :counter_cache_with_conditions_options
        self.counter_cache_with_conditions_options = []
      end

      ref = reflect_on_association(association_name)
      ref.klass.send(:attr_readonly, counter_name.to_sym) if ref.klass.respond_to?(:attr_readonly)
      if conditions.is_a? Proc
        conditions = [conditions.parameters.map{|_, name| name.to_s}, conditions]
      end
      self.counter_cache_with_conditions_options << [ref.klass, ref.foreign_key, counter_name, conditions]
    end

    module InstanceMethods
      private
      def counter_cache_with_conditions_after_create
        self.counter_cache_with_conditions_options.each do |klass, foreign_key, counter_name, conditions|
          if counter_conditions_match?(conditions)
            association_id = send(foreign_key)
            klass.increment_counter(counter_name, association_id) if association_id
          end
        end
      end

      def counter_cache_with_conditions_before_update
        self.counter_cache_with_conditions_options.each do |klass, foreign_key, counter_name, conditions|
          match_before = counter_conditions_without_changes_match?(conditions)
          match_now = counter_conditions_match?(conditions)
          if match_now && !match_before
            ccwc_update_counter_on(klass, foreign_key, counter_name, 1, 0)
          elsif !match_now && match_before && send("#{foreign_key}_changed?")
            # decrement only old, if association changed and condition broken
            ccwc_update_counter_on(klass, foreign_key, counter_name, 0, -1)
          elsif !match_now && match_before
            ccwc_update_counter_on(klass, foreign_key, counter_name, -1, -1)
          elsif match_now && send("#{foreign_key}_changed?")
            # if just association changed, decrement old, increment new
            ccwc_update_counter_on(klass, foreign_key, counter_name, 1, -1)
          end
        end
      end

      def counter_cache_with_conditions_before_destroy
        self.counter_cache_with_conditions_options.each do |klass, foreign_key, counter_name, conditions|
          if counter_conditions_without_changes_match?(conditions)
            association_was = attribute_was(foreign_key.to_s)
            klass.decrement_counter(counter_name, association_was) if association_was
          end
        end
      end

      def counter_conditions_match?(conditions)
        if conditions.is_a? Array # lambda
          attr_names, block = conditions
          block.call(*attr_names.map { |attr| send(attr) })
        else # hash
          # true is not strict like !!value
          conditions.all? { |attr, value| value == true ? send(attr) : send(attr) == value }
        end
      end

      def counter_conditions_without_changes_match?(conditions)
        if conditions.is_a? Array # lambda
          attr_names, block = conditions
          block.call(*attr_names.map { |attr| attribute_was(attr) })
        else # hash
          # true is not strict like !!value
          conditions.all? { |attr, value| value == true ? attribute_was(attr.to_s) : attribute_was(attr.to_s) == value }
        end
      end

      # e.g. increment counter on association, and decrement it on old association if association was changed, and vice versa
      # @param value (+1, 0, -1) value diff
      # @param value_was (0, -1) value for old association (if association was changed)
      def ccwc_update_counter_on(klass, foreign_key, counter_name, value, value_was = 0)
        association_id = send(foreign_key)
        klass.update_counters(association_id, counter_name => value) if association_id
        if value_was != 0
          # record was moved to another parent node, so we need to decrement counter on old parent node
          association_was = attribute_was(foreign_key.to_s)
          klass.update_counters(association_was, counter_name => value_was) if association_was && association_was != association_id
        end
      end

    end

  end
end
