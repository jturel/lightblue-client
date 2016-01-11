module Lightblue

  class Entity
    attr_reader :name
    def initialize(name = nil)
      @name = name
    end

    def [](arg)
      Lightblue::Expression.new.field(Lightblue::AST::Node.new(:field, [arg]))
    end

    def project(*projection)
      Lightblue::Query.new(self).project(projection)
    end

    def find(expr)
      Lightblue::Query.new(self).find(expr)
    end

    def unary_logical_operator(token, expr)
      expr = AST::Node.new(:unary_logical_expression,
                           [
                             AST::Node.new(:unary_logical_operator, [token]),
                             @ast, expr.ast
                           ].flatten.compact
                          )

      Lightblue::Query.new(self).find(expr)
    end
    AST::Tokens::OPERATORS[:unary_logical_operator].each do |token|
      define_method(token.to_s.delete('$')) { |expr = nil| unary_logical_operator(token, expr) }
    end

  end
end
