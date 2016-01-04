module Lightblue
  class Query
    def initialize(entity)
      @entity = entity
      @expression = Lightblue::Expression.new
    end

    def find(expression)
      @expression = @expression.find(expression)
      self
    end


    AST::Tokens::OPERATORS[:nary_logical_operator].each do |token|
      define_method(token.to_s.gsub('$','')) do |*expr|
        @expression = @expression.nary_logical_operator(token, expr)
        self
      end
    end

    AST::Tokens::OPERATORS[:unary_logical_operator].each do |token|
      define_method(token.to_s.gsub('$','')) do |*expr|
        @expression = @expression.unary_logical_operator(token, expr)
        self
      end
    end

    def to_h
      { entity: @entity.name }
    end

    def ast
      @expression.ast
    end

    def to_hash
      v, _ = *Lightblue::AST::Visitors::DepthFirst.new do |v|
        v.pre_order Lightblue::AST::Visitors::ExpandExpressionArgumentsVisitor.new
        v.pre_order Lightblue::AST::Visitors::Validation.new
        v.in_order Lightblue::AST::Visitors::HashVisitor.new
      end.process(@expression.ast)
      v
    end
    def json
    end
  end
end
