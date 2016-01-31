module Lightblue
  module AST
    module Visitors
      class ProjectionBindVisitor < AST::Visitor
        def on_unbound_match_expression(ast)
          field, query = *ast
          Lightblue::AST.unfold ast.updated(:array_match_projection,
                                            [field, true, query, nil, nil])
        end

        def handler_missing(ast)
        end
      end
    end
  end
end
