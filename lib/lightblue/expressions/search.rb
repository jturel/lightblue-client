module Lightblue
  module Expressions
    class Search < Lightblue::Expression

      # @param [Symbol, String] name
      # @return [Expression]
      def field(name)
        Expression.new @ast.concat([Lightblue::AST::Node.new(:field, [name])])
      end


      Lightblue::AST::Tokens::OPERATORS[:binary_comparison_operator].each do |token|
        define_method(token.to_s.delete('$')) { |expr = nil| binary_comparison_operator(token, expr) }
      end

      private
      def self.ast_root
        new_node(:query_expression, [])
      end
    end
  end
end
