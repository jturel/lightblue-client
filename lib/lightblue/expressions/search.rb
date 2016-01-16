module Lightblue
  module Expressions
    class Search < Lightblue::Expression

      include Operators::BinaryComparison
      # @param [Symbol, String] name
      # @return [Expression::SearchExpression]
      def field(name)
        Search.new ast.concat([Lightblue::AST::Node.new(:field, [name])])
      end

      alias_method :[], :field

      private
      # @param [Symbol] token
      # @param [Search, Symbol, Integer, String] expression
      # @raises [BadParamOrdering] 
      # @return [Search]
      def binary_comparison_operator(token, expression)
        raise Operators::BadParamOrdering, 'Bad Error Message' unless first_param_is_field?
        expression = case expression
                     when Expression then expression.ast
                     else literal_to_node(expression)
                     end
        new_ast = ast.concat([new_node(:op, [token]), expression])
        self.class.new(new_ast)
      end

      # @return [Boolean] 
      def first_param_is_field?
        child, = *ast
        return false if child.nil?
        case child.type
        when :field then true
        else false
        end
      end

      def self.ast_root
        new_node(:query_expression, [])
      end
    end
  end
end
