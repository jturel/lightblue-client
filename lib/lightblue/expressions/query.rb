module Lightblue
  module Expressions
    class Query < Lightblue::Expression
      include Operators::BinaryComparison
      include Operators::NaryComparison
      include Operators::UnaryLogical
      include Operators::NaryLogical

      def initialize(ast = nil)
        ast ||= new_node(:query_expression, [])
        super ast
      end

      # @param [Symbol, String, Field] expression
      # @return [Expressions::Field]
      def field(expression)
        node = case expression
               when Field then expression.ast
               else
                 new_node(:field, [expression])
               end
        klass.new ast.concat([node])
      end

      private

      # @param [Symbol] token
      # @param [Field, Symbol, Integer, String] expression
      # @return [Query]
      def binary_comparison_operator(token, expression)
        expression = case expression
                     when Field then expression.ast
                     else literal_to_node(expression)
                     end
        new_ast = ast.concat([new_node(:binary_comparison_operator, [token]), expression])
        klass.new(new_ast)
      end

      # @param [Symbol] token
      # @param [Field, Array<Symbol, String>] expression
      # @return [Query]
      def nary_comparison_operator(token, expression)
        expression = case expression
                     when Field then expression.ast
                     when Array then literal_to_node(expression)
                     else fail Errors::BadParamForOperator.new(token, expression)
                     end
        new_ast = ast.concat([new_node(:nary_comparison_operator, [token]), expression])
        klass.new(new_ast)
      end

      # @param [Symbol] token
      # @param [Array<Query>] expression
      # @return [Query]
      def nary_logical_operator(token, expressions)
        fail Errors::BadParamForOperator.new(token, expressions) unless
          expressions.is_a?(Array) && expressions.all? { |exp| exp.is_a?(Query) }

        klass.new new_node(:nary_logical_expression,
                           [new_node(:nary_logical_operator, [token]),
                            new_node(:query_array, expressions.map { |e| e.ast })])
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
