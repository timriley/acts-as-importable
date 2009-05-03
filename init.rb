$:.unshift "#{File.dirname(__FILE__)}/lib"
require 'core_extensions'
require 'acts_as_importable'
ActiveRecord::Base.class_eval { include AMC::Acts::Importable }