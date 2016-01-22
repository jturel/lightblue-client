module Lightblue
  class Projection
    class IncompatibleProjectionParameters < StandardError; end
    def initialize(field, entity)
      @field = field
      @include = nil
      @recursive = nil
      @projection_type = :field_projection
      @projection = nil
      @sub_sort = nil
      @entity = entity
    end

    def include(bool = true)
      @include = bool
      self
    end

    def recursive(bool = true)
      @recursive = bool
      self
    end

    def range(first, last)
      if @projection_type == :array_match_projection
        fail IncompatibleProjectionParameters, 'Attempted to set range param  on a match projection'
      end
      @include = true if @include.nil?

      @projection_type = :array_range_projection
      @range = [first, last]
      self
    end

    def match(query = nil, &blk)
      if @projection_type == :array_match_projection
        fail IncompatibleProjectionParameters, 'Attempted to set match param on a range projection'
      end

      @include = true if @include.nil?
      @projection_type = :array_match_projection
      @match = Lightblue::FindManager.new(@entity).find(query, &blk).ast
      self
    end

    def project(expr = nil, &blk)
      fail 'Project can accept either an expression or a block' if expr && blk

      add_projection(ProjectionManager.new(@entity).project(&blk)) if blk

      case expr
      when Array
        expr.each { |proj| add_projection proj }
      when Lightblue::Projection
        add_projection expr
      end
      self
    end

    def ast
      expression.ast
    end

    def to_hash
      expression.to_hash
    end

    private

    def add_projection(projection)
      if !@projection
        @projection = AST::Node.new(:maybe_projection, [projection.ast])
      elsif @projection && @projection.type == :projection
        @projection = AST::Node.new(:projection,
                                    AST::Node.new(:basic_projection_array,
                                                  [*@projection,
                                                   projection]))
      end
    end

    def expression
      ast = case @projection_type
            when :field_projection
              AST::Node.new(:field_projection, [@field, @include, @recursive])
            when :array_match_projection
              AST::Node.new(:array_match_projection, [@field, @include, @match, @projection, @sort])
            when :array_range_projection
              AST::Node.new(:array_range_projection, [@field, @include, @range, @projection, @sort])
            end
      Lightblue::Expression.new.apply_ast(ast)
    end
  end

  class ProjectionManager
    attr_reader :entity
    def initialize(entity)
      @entity = entity
      @projections = []
    end

    def project(expr = nil, &blk)
      @projections << expr if expr
      instance_eval(&blk) if blk
      self
    end

    def field(field)
      f = Projection.new(field, @entity)
      @projections << f
      f
    end

    def ast
      if @projections.count > 1
        AST::Node.new(:basic_projection_array, @projections.map(&:ast))
      elsif @projections.count == 1
        @projections.first.ast
      end
    end
  end
end
