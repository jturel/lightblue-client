module Lightblue
  class Query
    def initialize(entity)
      @entity = entity
      @expression = Lightblue::Expression.new
      @projection = []
    end

    def project(&blk)
      @projections = Lightblue::Projection.new(&blk)
      self
    end

    def find(expr)
      @expression = @expression.find(expr)
      self
    end

    def to_h
      { entity: @entity.name }
    end

    def ast
      @expression.ast
    end

    def to_hash

      p = Lightblue::AST::Visitors::UnfoldVisitor.new.process(@expression.ast)
      p = Lightblue::AST::Visitors::Validation.new.process(p)
      v, _t  = *Lightblue::AST::Visitors::HashVisitor.new.process(p)

      v
    end
  end
end
