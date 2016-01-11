module Lightblue
  module AST
    module Visitors
      class HashVisitor < Lightblue::AST::Visitor

        # This folds union types
        def on_union(node)
          node.updated(nil, process(*node))
        end
        handle_with :on_union, Lightblue::AST::Tokens::UNIONS.keys

        def on_expression(node)
          fields = Lightblue::AST::Tokens::EXPRESSIONS[node.type].map(&:keys).flatten
          hash = {}

          node.each_with_index  do |child, index|
            oc = child.dup
            if child.terminal?
              #noop
            else
              child = process(child)
            end
            next if child.nil? || child.type == :empty || child == :empty
            hash[fields[index]], _ = *child
          end
          node.updated(nil, [hash])
        end
        handle_with :on_expression, Lightblue::AST::Tokens::EXPRESSIONS.keys

        def on_unary_logical_expression(node)
          hash = {}
          op, query = *node

          sub_query, _tail = *process(query)
          hash[*op] = sub_query

          node.updated(nil, [hash])
        end

        def on_expression_array(node)
          node.updated(nil, process_all(node))
        end
        handle_with :on_expression_array, [:query_array, :basic_projection_array]

        def on_nary_logical_expression(node)
          op, children = *process_all(node)
          node.updated(nil, [{ op => children.map(&:children).flatten }])
        end

        def on_terminals(node)
          value, tail = *node
          value
        end
        handle_with :on_terminals, Lightblue::AST::Tokens::TERMINALS
        handle_with :on_terminals, [:maybe_boolean, :maybe_sort]

        def on_maybe_projection node
          value, = *node.updated(nil, process_all(node))
          value
        end
      end
    end
  end
end
