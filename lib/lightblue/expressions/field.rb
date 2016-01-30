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

      # @param [Regexp, String, Expressions::Query] expression
      # @param [Hash{Symbol => Boolean}] regex_options
      # @option regex_options [Boolean] :dotall
      # @option regex_options [Boolean] :multiline
      # @option regex_options [Boolean] :case_insensitive
      # @option regex_options [Boolean] :extended
      def match(expression, regex_options = {})
        new_ast = case expression
                  when Expression then new_node(:array_match_expression, [ast, expression.ast])
                  when String then build_regexp_node(expression, regex_options)
                  when Regexp then build_regexp_node(expression, regex_options)
                  else fail Errors::BadParamForOperator.new(token, expression)
                  end
        Unbound.new(new_ast)
      end

      private

      # @TODO extract regex options
      def build_regexp_node(regexp, regex_options = {})

        parameters = AST::Tokens::EXPRESSIONS[:regex_match_expression][2..-1].map(&:keys).flatten
        options = parameters.map { |key| new_node(:maybe_boolean, [regex_options[key]]) }

        new_node(:regex_match_expression, [ast,
                                           new_node(:pattern, [regexp])].concat(options))
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
