module Lightblue
  module Expressions
    class Query < Lightblue::Expression
      include Operators::UnaryLogical
      include Operators::NaryLogical

      # @param [AST::Node, Expressions::Unbound, nil] expression
      def initialize(expression = nil)
        ast = case expression
              when Expressions::Unbound then expression.ast
              when AST::Node then expression
              when nil then new_node(:query_expression, [])
              end
        super ast
      end

      private

      # @param [Symbol] token
      # @param [Array<Query>] expression
      # @return [Query]
      def nary_logical_operator(token, expressions)
        valid = expressions.is_a?(Array) && expressions.all? { |exp| exp.is_a?(Expression) }

        fail Errors::BadParamForOperator.new(token, expressions) unless valid
        klass.new new_node(:nary_logical_expression,
                           [new_node(:nary_logical_operator, [token]),
                            new_node(:query_array, expressions.map { |e| Lightblue::AST.unfold e.ast })])
      end

      # @param [Symbol] token
      # @param [Query] expression
      # @return [Query]
      def unary_logical_operator(token, expression)
        fail Errors::BadParamForOperator.new(token, expression) unless expression.is_a?(Query)
        klass.new new_node(:unary_logical_expression,
                           [new_node(:unary_logical_operator, [token]),
                            expression.ast])
      end
    end
  end
end
