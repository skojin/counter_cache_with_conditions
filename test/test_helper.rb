require 'rubygems'
require 'active_support'
require 'active_record'
require 'test/unit'


def load_schema
  conf = YAML::load(File.open(File.dirname(__FILE__) + '/database.yml'))
  ActiveRecord::Base.logger = Logger.new(File.dirname(__FILE__) + "/debug.log") 

  ActiveRecord::Base.establish_connection(conf['sqlite3'])
  load(File.dirname(__FILE__) + "/schema.rb")
end
