module Lightblue
  class Entity
    attr_reader :name, :version
    def initialize(name, version = nil)
      @name = name
      @version = version
    end

    def project(expr = nil, &blk)
      Lightblue::Query.new(self).project(expr, &blk)
    end

    def find(expr = nil, &blk)
      Lightblue::Query.new(self).find(expr, &blk)
    end

    def not(expr = nil, &blk)
      q = Lightblue::Query.new(self)
      q.find_manager.unary_logical_operator(:$not, expr, &blk)
      q
    end
  end
end
