require 'lightblue/expression'
module Lightblue
  module Expressions
    class Field < Expression
      include Operators::BinaryComparison
      include Operators::NaryComparison
      def initialize(name)
        super new_node(:field, [name])
      end

      # @param [Symbol] token
      # @param [Field, Symbol, Integer, String] expression
      # @return [Query]
      def binary_comparison_operator(token, expression)
        type, expression = case expression
                           when Field then [:field_comparison_expression, expression.ast]
                           else [:value_comparison_expression, literal_to_node(expression)]
                           end

        new_ast = new_node(type, [ast,
                                  new_node(:binary_comparison_operator, [token]),
                                  expression])
        Unbound.new(new_ast)
      end

      # @param [Symbol] token
      # @param [Field, Array<Symbol, String>] expression
      # @return [Query]
      def nary_comparison_operator(token, expression)
        type, expression = case expression
                           when Field
                             [:nary_field_comparison_expression, expression.ast]
                           when Array
                             [:nary_value_comparison_expression, literal_to_node(expression)]
                           else fail Errors::BadParamForOperator.new(token, expression)
                           end

        new_ast = new_node(type, [ast,
                                  new_node(:nary_comparison_operator, [token]),
                                  expression])
        Unbound.new(new_ast)
      end
    end
  end
end
