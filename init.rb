require 'counter_with_conditions'
ActiveRecord::Base.module_eval do
  extend CounterWithConditions
end
