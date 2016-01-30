require 'lightblue/expression'
module Lightblue
  module Expressions
    class Field < Expression
      include Operators::BinaryComparison
      include Operators::NaryComparison
      include Operators::ArrayComparison

      # @param [Symbol, String] name
      def initialize(name)
        super new_node(:field, [name])
      end

      # @param [Symbol] token
      # @param [Field, Symbol, Integer, String] expression
      # @return [Expressions::Unbound]
      def binary_comparison_operator(token, expression)
        type, expression =
          case expression
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
      # @return [Expressions::Unbound]
      def nary_comparison_operator(token, expression)
        type, expression =
          case expression
          when Field then [:nary_field_comparison_expression, expression.ast]
          when Array then [:nary_value_comparison_expression, literal_to_node(expression)]
          else fail Errors::BadParamForOperator.new(token, expression)
          end
        new_ast = new_node(type, [ast,
                                  new_node(:nary_comparison_operator, [token]),
                                  expression])
        Unbound.new(new_ast)
      end

      def array_contains_operator(token, expression)
        expression =
          case expression
          when Array then literal_to_node(expression)
          else fail Errors::BadParamForOperator.new(token, expression)
          end
        new_ast = new_node(:array_contains_expression,
                           [ast,
                            new_node(:array_contains_operator, [token]),
                            expression])
        Unbound.new(new_ast)
      end
    end
  end
end
