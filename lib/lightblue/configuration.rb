module Lightblue
  module Configuration
    VALID_KEYS = [:data_base_uri, :metadata_base_uri].freeze

    attr_accessor *VALID_KEYS

    def options
      Hash[ *VALID_KEYS.map {|k| [k,send(k)] }.flatten ]
    end

    def configure
      yield self
    end

  end
end
