module CounterCacheWithConditions
  class Railtie < Rails::Railtie
    initializer 'counter_cache_with_conditions.insert_into_active_record' do
      ActiveSupport.on_load :active_record do
        ::ActiveRecord::Base.extend(ActiveRecord)
      end
    end
  end
end