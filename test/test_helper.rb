$:.unshift(File.dirname(__FILE__) + '/../lib')
require "bundler/setup"
require "minitest/autorun"

require "active_record"
require "yaml"
require "counter_cache_with_conditions"

puts  "Rails #{ActiveSupport::VERSION::STRING}"

if ActiveSupport::TestCase.respond_to?(:test_order=)
  ActiveSupport::TestCase.test_order = :random
end

def load_schema
  conf = YAML::load(File.open(File.dirname(__FILE__) + '/database.yml'))

  ActiveRecord::Base.establish_connection(conf['sqlite3'])
  # ActiveRecord::Base.logger = Logger.new(File.dirname(__FILE__) + "/debug.log") 
  load(File.dirname(__FILE__) + "/schema.rb")
end
