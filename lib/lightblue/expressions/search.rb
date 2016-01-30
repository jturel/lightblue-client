module Lightblue
  module Expressions
    class Search < Lightblue::Expression
      include Operators::BinaryComparison
      include Operators::NaryComparison
      # @param [Symbol, String] name
      # @return [Expression::FieldExpression]
      def field(name)
        Search.new ast.concat([Lightblue::AST::Node.new(:field, [name])])
      end

      alias_method :[], :field

      private
      # @param [Symbol] token
      # @param [Search, Symbol, Integer, String] expression
      # @raise [BadParamOrdering]
      # @return [Search]
      def binary_comparison_operator(token, expression)
        fail Operators::BadParamOrdering, 'Bad Error Message' unless first_param_is_field?
        expression = case expression
                     when Expression then expression.ast
                     else literal_to_node(expression)
                     end
        new_ast = ast.concat([new_node(:binary_comparison_operator, [token]), expression])
        klass.new(new_ast)
      end

      # @param [Symbol] token
      # @param [Field, Array<Symbol, String>] expression
      # @raise [BadParamOrdering]
      # @return [Search]
      def nary_comparison_operator(token, expression)
        fail Operators::BadParamOrdering, 'Bad Error Message' unless first_param_is_field?
        expression = case expression
                     when Expression then expression.ast
                     else literal_to_node(expression)
                     end
        new_ast = ast.concat([new_node(:nary_comparison_operator, [token]), expression])
        #`Lightblue::AST.valid? new_ast
        klass.new(new_ast)
      end

      # @return [Boolean]
      def first_param_is_field?
        child, = *ast
        return false if child.nil?
        child.type == :field
      end

      def self.ast_root
        new_node(:query_expression, [])
      end
    end
  end
end
