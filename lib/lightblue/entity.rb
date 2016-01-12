module Lightblue
  class Entity
    attr_reader :name, :version
    def initialize(name, version = nil)
      @name = name
      @version = version
    end

    def project(expr = nil, &blk)
      Lightblue::ProjectionManager.new(self).project(expr, &blk)
    end

    def find(expr = nil, &blk)
      Lightblue::FindManager.new(self).find(expr, &blk)
    end

    def not(expr = nil, &blk)
      Lightblue::FindManager.new(self).unary_logical_operator(:$not, expr, &blk)
    end
  end
end
