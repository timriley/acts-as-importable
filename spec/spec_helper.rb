ENV['RAILS_ENV'] = 'test'
$:.unshift(File.dirname(__FILE__) + '/../lib')

require 'rubygems'
require 'active_record'
require File.dirname(__FILE__) + '/../init.rb'

require 'spec'

config = YAML::load(IO.read(File.dirname(__FILE__) + '/database.yml'))
ActiveRecord::Base.logger = Logger.new(File.dirname(__FILE__) + "/debug.log")
ActiveRecord::Base.establish_connection(config[ENV['DB'] || 'sqlite3mem'])

ActiveRecord::Migration.verbose = false
load(File.dirname(__FILE__) + "/schema.rb")

class Thing < ActiveRecord::Base
end

module Legacy
  class Thing < ActiveRecord::Base
    set_table_name 'legacy_things'
    
    acts_as_importable
  
    def to_model
      ::Thing.new do |t|
        t.name        = self.legacy_name
        t.description = self.legacy_description
      end
    end
  end
  
  class OtherThing < Thing
    set_table_name 'legacy_things'
    
    acts_as_importable :to => 'Thing'
  end
end

Spec::Runner.configure do |config|
  
  def create_legacy_thing(attrs = {})
    Legacy::Thing.create({:legacy_name => 'Grandfather Clock', :legacy_description => 'Tick tock'}.merge(attrs))
  end
  
  def create_other_legacy_thing(attrs = {})
    Legacy::OtherThing.create({:legacy_name => 'Grandfather Clock', :legacy_description => 'Tick tock'}.merge(attrs))
  end
end