module Lightblue
  module HTTP

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
