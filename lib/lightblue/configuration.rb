module Lightblue
  module Configuration
    VALID_KEYS = [:data_base_uri, :metadata_base_uri].freeze

    attr_accessor *VALID_KEYS

    def self.options
      Hash[ *VALID_KEYS.map {|k| [k,self.send(k)] }.flatten ] 
    end

    def self.metadata_base_uri
    end
    def self.data_base_uri
    end

  end
end
