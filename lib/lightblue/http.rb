require 'faraday'
module Lightblue
  module HTTP
    # I was using this for testing. We can do whatever we want with the client side,
    # although Faraday is really nice.
    def get(*args, &block)
      connection.get(*args, &block)
    end

    def put(*args, &block)
      connection.put(*args, &block)
    end

    def delete(*args, &block)
      connection.delete(*args, &block)
    end

    def post(*args, &block)
      connection.post(*args, &block)
    end

    def connection
      Faraday.new(url: host_uri)
    end
    private :connection
  end
end
