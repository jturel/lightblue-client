require 'faraday'
module Lightblue
  module HTTP
    # I was using this for testing. We can do whatever we want with the client side,
    # although Faraday is really nice.
    def self.find(query)
      connection.post do |con|
        con.url "rest/data/find/#{query.entity.name}/1.0.0"
        con.headers['Content-Type'] = 'application/json'
        con.body = query.to_hash.to_json
      end
    end

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

    def self.connection
      Faraday.new(url: URL)
    end
  end
end
