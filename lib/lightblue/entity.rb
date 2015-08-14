require 'lightblue/ast'

module Lightblue

  class Entity
    def initialize(name)
     @name = name
    end

    def where(query)
      Lightblue::AST::Nodes::Query.new(query)
    end

    def [](arg)
      Lightblue::AST::Nodes::Field.new(arg)
    end
  end

end
