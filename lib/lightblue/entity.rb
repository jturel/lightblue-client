module Lightblue
  class Entity
    attr_reader :name
    def initialize(name = nil, options = {})
      @name = name
    end

    def [](arg)
      Lightblue::Expression.new.field(Lightblue::AST::Node.new(:field, [arg]))
    end

    def project(projection)
      Lightblue::Query.new(self).project(projection)
    end

    def find(expression)
      Lightblue::Query.new(self).find(expression)
    end
  end
end
