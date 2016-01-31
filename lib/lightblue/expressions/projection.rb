module Lightblue
  module Expressions
    class Projection < Lightblue::Expression
      # @param [Unbound, Field, AST::Node, Array<Unbound, Field, AST::Node>, nil] expression
      def initialize(expression = nil)
        ast = case expression
              when Expressions::Unbound then expression.bind(:projection)
              when Expressions::Field then new_node(:field_projection, [expression.ast])
              when AST::Node then expression
              when Array
                expressions = expression.map { |p| Projection.new(p).ast }
                new_node(:projection, [new_node(:basic_projection_array, expressions)])
              when nil then new_node(:projection, [])
              end
        super ast
      end
    end
  end
end
