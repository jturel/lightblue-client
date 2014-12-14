require 'lightblue/configuration'
module Lightblue
  extend Configuration
  class Client
    VERSION = '0.0.1'

    attr_accessor *Configuration::VALID_KEYS

    def initialize(options={})

      all_options = Configuration.options.merge(options)
      puts all_options.inspect
      Configuration::VALID_KEYS.each { |k| send("#{k}=", all_options[k]) } 
      puts Configuration::options.inspect

    end

    def self.configure
      yield self
    end

  end
end
