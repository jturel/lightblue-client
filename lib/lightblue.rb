require 'lightblue/ast'
require 'lightblue/client'
require 'lightblue/entity'
require 'lightblue/visitors'
require 'lightblue/version'
require 'lightblue/metadata'
require 'lightblue/railtie' if defined?(Rails)

module Lightblue
  def self.resources
    Pathname.new(File.expand_path '../resources', File.dirname(__FILE__))
  end
end
