module Lightblue
  module AST
    module Visitors
      class QueryBindVisitor < AST::Visitor
        def on_unbound_value_comparison_expression(ast)
          ast.updated(:value_comparison_expression, ast.children)
        end

        def on_unbound_match_expression(ast)
          ast.updated(:array_match_expression, ast.children)
        end
      end
    end
  end
end
