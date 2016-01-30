module Lightblue
  module Expressions
    class Query < Lightblue::Expression
      include Operators::BinaryComparison
      include Operators::NaryComparison

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
        Query.new ast.concat([node])
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
    end
  end
end
