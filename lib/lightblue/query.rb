module Lightblue
  # Entry point to the primary DSL
  class Query
    def initialize(entity)
      @entity = entity
      @find_manager = Lightblue::FindManager.new(@entity)
      @projection_manager = Lightblue::ProjectionManager.new(@entity)
    end

    def project(expr = nil, &blk)
      @projection_manager.project(expr, &blk)
      self
    end

    def find_manager
      @find_manager
    end

    def find(expr = nil, &blk)
      @find_manager.find(expr, &blk)
      self
    end

    # TODO
    def client
    end

    # TODO
    def execution
    end

    def to_ast
      find = validate(unfold(@find_manager.ast))
      projections = validate(unfold(@projection_manager.ast))

      AST::Node.new(:request,
                    [
                      AST::Node.new(:object_type, [@entity.name]),
                      AST::Node.new(:request_query, [find]),
                      AST::Node.new(:request_projection, [projections])
                      # TODO
                      # AST::Node.new(:maybe_object_version, [@entity.version]),
                      # AST::Node.new(:client, [@client]),
                      # AST::Node.new(:execution, [@execution]),
                      # AST::Node.new(:sort, [@sort]),
                    ])
    end

    def to_hash
      ast_to_hash(to_ast)
    end

    private

    def projection_hash
      h, = *ast_to_hash(validate(unfold(find_ast)))
      h
    end

    def projection_ast
      @projection_manager.ast
    end

    def find_ast
      @find_manager.ast
    end

    def find_hash
      h, = *ast_to_hash(validate(unfold(find_ast)))
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
