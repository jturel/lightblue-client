module Lightblue
  # The Query class is the primary entry point to the DSL. It exposes builder methods corresponding to each Data API endpoint, which delegate to a
  # delegate to a Lightblue::Manager subclass, which is responsible for generating and composing expressionsn.
  # @see Lightblue::Manager
  class Request
    def find(entity, expression, &blk)
    end

    def update(entity, expression, &blk)
    end

    def insert(entity, expression, &blk)
    end

    def delete(entity, expression, &blk)
    end

    def save(entity, expression, &blk)
    end
  end
end
=begin

    attr_reader :find_manager, :projection_manager
    def initialize(entity)
      @entity = entity
      @find_manager = Lightblue::FindManager.new(@entity)
      @projection_manager = Lightblue::ProjectionManager.new(@entity)
    end

    # @!group Query Constructors

    def project(expr = nil, &blk)
      @projection_manager.project(expr, &blk)
      self
    end
    # @!endgroup

    # @!group Query Constructors
    def find(expr = nil, &blk)
      @find_manager.find(expr, &blk)
      self
    end
    # @!endgroup

    # TODO
    def client
    end

    # TODO
    def execution
    end

    def to_hash
      { entity: @entity.name,
        entityVersion: @entity.version,
        query: find_hash,
        projection: [projection_hash].flatten
      }.delete_if { |_, v| v.nil? }
    end

    private

    def projection_hash
      if projection_ast
        p = ast_to_hash(validate(unfold(projection_ast)))
        if p.type == :basic_projection_array
          p.children.map(&:children).flatten
        else
          p.children
        end
      end
    end

    def projection_ast
      @projection_manager.ast
    end

    def find_ast
      @find_manager.ast
    end

    def find_hash
      h, = *ast_to_hash(validate(unfold(find_ast))) if find_ast
      h
    end

    def ast_to_hash(ast)
      Lightblue::AST::Visitors::HashVisitor.new.process(ast)
    end

    def unfold(ast)
      Lightblue::AST::Visitors::UnfoldVisitor.new.process(ast)
    end

    def validate(ast)
      Lightblue::AST::Visitors::ValidationVisitor.new.process(ast)
    end
  end
end
=end
