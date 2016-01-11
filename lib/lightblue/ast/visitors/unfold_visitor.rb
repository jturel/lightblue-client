module Lightblue
  module AST
    module Visitors
      # This processor takes nodes or raw values passed into an expression node and expands them (so that the validation
      # visitor can process them.

      class UnfoldVisitor < AST::Visitor
        def on_union(node)
          node.updated(nil, process_all(node))
        end
        handle_with :on_union, Lightblue::AST::Tokens::UNIONS.keys

        def on_expression(node)
          node.updated(nil, process_all(node))
        end
        handle_with :on_expression, Lightblue::AST::Tokens::EXPRESSIONS.keys

        def on_query_array(node)
          node.updated(nil, process_all(node))
        end

        def on_nullable_expression(node)
          parameters = AST::Tokens::EXPRESSIONS[node.type]
          children = parameters.zip(node).map do |param, v|
            v = :empty if v.nil?
            v.is_a?(AST::Node) ? process(v) : process(AST::Node.new(param.values.first, [v]))
          end
          node.updated(nil, children)
        end
        handle_with :on_nullable_expression,
                    [:regex_match_expression,
                     :array_match_projection,
                     :array_range_projection,
                     :field_projection]

        def handler_missing(node)
        end

        def on_terminal(node)
          node
        end
        handle_with :on_terminal, Lightblue::AST::Tokens::TERMINALS

        def on_maybe(node) # rubocop:disable Metrics/CyclomaticComplexity
          child, = *node
          return node.updated(nil, [AST::Node.new(:empty, [nil])]) if child == :empty || child.nil?
          return node.updated(nil, process_all(node)) if child.is_a? AST::Node

          key = case node.type
                when :maybe_boolean then :boolean
                when :maybe_sort then :sort
                when :maybe_projection
                  if child.is_a? Array
                    :basic_projection_array
                  else
                    :projection
                  end
                end
          node.updated(nil, [AST::Node.new(key, [child])])
        end
        handle_with :on_maybe, [:maybe_boolean,
                                :maybe_sort,
                                :maybe_projection]
      end
    end
  end
end
