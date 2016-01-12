module Lightblue
  # Entry point to the primary DSL
  #
  # Query Constructors accept either an instance of {Expression}, or a
  # block which will be executed in the scope of the Manager class (Find, Sort, Project) being called.
  #
  # In General, you should use a block to construct a new expression. Then, once the expression has been generated,
  # you can use it to compose other queries.
  #
  # @example
  #   Query.new(:foo).find { field[:bar].eq(:batz) }

  class Query
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
