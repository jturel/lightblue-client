module Lightblue
  module AST
    module Visitors
      class ExpandExpressionArgumentsVisitor < AST::Visitor
        def on_nullable_expression(node)
          parameters = AST::Tokens::EXPRESSIONS[node.type]
          children = parameters.zip(node).map do |param, v|
            v = :empty if v.nil?
            v.is_a?(AST::Node) ? v : AST::Node.new(param.values.first, [v])
          end

          node.updated(nil, children)
        end
        multi_alias :on_nullable_expression, [
                      :regex_match_expression,
                      :array_match_projection,
                      :array_range_projection,
                      :field_projection ]

        def on_expression(node)
        end
        multi_alias :on_nullable_expression, Lightblue::AST::Tokens::EXPRESSIONS.keys
        def on_terminal(node)
        end
        multi_alias :on_terminal, Lightblue::AST::Tokens::TERMINALS

        def on_maybe(node)
          child, _ = *node
          return node.updated(nil, [AST::Node.new(:empty, [nil])]) if child == :empty

          key = case node.type
                when :maybe_boolean; :boolean
                when :maybe_sort; :sort
                when :maybe_projection; :projection
                end
          node.updated(nil, [AST::Node.new(key, [child])])
        end
        multi_alias :on_maybe, [ :maybe_boolean,
                               :maybe_sort,
                               :maybe_projection ]
      end
    end
  end
end
