module Lightblue
  class Projection
    class IncompatibleProjectionParameters < StandardError; end
    def initialize(field)
      @field = field
      @include = nil
      @recursive = nil
      @projection_type = :field_projection
      @projection = nil
      @sub_sort = nil
    end

    def include(bool = true)
      @include = bool
      self
    end

    def recursive(bool = true)
      @recursive = bool
      self
    end

    def !
      @include = !@include
      self
    end

    def range(first, last)
      if @projection_type == :array_match_projection
        raise IncompatibleProjectionParameters, 'Attempted to set range param  on a match projection'
      end
      @projection_type = :array_range_projection
      @range = [first, last]
      self
    end

    def match(query)
      if @projection_type == :array_match_projection
        raise IncompatibleProjectionParameters, 'Attempted to set match param on a range projection'
      end
      @projection_type = :array_match_projection
      @match = query.ast
      self
    end

    def sort(sort)
      @projection_type = :unresolved if @projection_type == :field_projection
      @sort = sort
      self
    end

    def project(expr, &blk)
      @projection_type = :unresolved if @projection_type == :field_projection

      if blk
        add_projection ProjectionManager.new(&blk)
        return self
      end
      case expr
      when Array
        expr.each {|proj| add_projection proj }
      when Lightblue::Projection
        add_projection expr
      else
      end
      self
    end

    def to_ast
      expression.ast
    end

    def to_hash
      h, _ = *expression.to_hash
      h
    end

    private
    def add_projection(projection)
      if !@projection
        @projection = AST::Node.new(:maybe_projection, [projection.to_ast])
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

    def initialize(&blk)
      @fields = []
      instance_eval(&blk)
    end

    def field(field)
      f = Projection.new(field)
      @fields << f
      f
    end

    def [](arg)
      puts "hi"
    end
  end
end
