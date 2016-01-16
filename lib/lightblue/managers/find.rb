module Lightblue
  class Find < Lightblue::Manager
    def ast_root
      Lightblue::AST::Node.new(:query_expression, [])
    end

    def field(name)
      ast = @ast.concat(node(:field, name))
      Expression.new(ast)
    end
  end
end
=begin
      attr_reader :entity
      def initialize(entity)
        @entity = entity
      end

      def find(expr = nil, &blk)
        @expression = case expr
                      when Lightblue::Query
                        Lightblue::Expression.new.apply_ast(expr.send(:find_ast))
                      when Lightblue::Expression
                        expr
                      when nil
                        instance_eval(&blk)
                      end
      end

      def field
        Lightblue::Expression.new
      end
      alias_method :f, :field

      def ast
        @ast
      end

      def unary_logical_operator(token, expr = nil)
        expr = AST::Node.new(:unary_logical_expression,
                             [
                               AST::Node.new(:unary_logical_operator, [token]),
                               expr.ast
                             ].flatten
                            )
        @expression = Lightblue::Expression.new.apply_ast(expr)
      end
    end
  end
end
=end
