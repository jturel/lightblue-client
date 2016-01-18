module Lightblue
  class FindManager
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

    def ast
      @expression.ast
    end

    def unary_logical_operator(token, expr = nil, &blk)
      expr = instance_eval(&blk) if blk
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
