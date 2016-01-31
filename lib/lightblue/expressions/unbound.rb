require 'lightblue/expression'
module Lightblue
  module Expressions
    class Unbound < Expression
      # @param [Symbol] expression_type :query | :projection | :sort
      def bind(expression_type)
        case expression_type
        when :query then Lightblue::AST::Visitors::QueryBindVisitor.new.process(ast)
        when :projection then Lightblue::AST::Visitors::ProjectionBindVisitor.new.process(ast)
        end
      end
    end
  end
end
