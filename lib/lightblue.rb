require 'lightblue/ast'
require 'lightblue/client'
require 'lightblue/entity'
require 'lightblue/query'
require 'lightblue/expression'
require 'lightblue/projection'
require 'lightblue/find_manager'
require 'lightblue/version'
require 'lightblue/metadata'
require 'lightblue-client/railtie' if defined?(Rails)

module Lightblue
  def self.resources
    Pathname.new(File.expand_path '../resources', File.dirname(__FILE__))
  end
end
