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
          node.each_with_index do |child, index|
            child = process(child) unless child.terminal?
            next if child.nil? || child.type == :empty || child == :empty
            hash[fields[index]], = *child
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
          node.updated(nil, [process_all(node).map(&:children).flatten])
        end
        handle_with :on_expression_array, [:query_array, :basic_projection_array]

        def on_nary_logical_expression(node)
          op, children = *process_all(node)
          node.updated(nil, [{ op => children.children.flatten }])
        end

        def on_terminals(node)
          value, = *node
          value
        end
        handle_with :on_terminals, Lightblue::AST::Tokens::TERMINALS
        handle_with :on_terminals, [:maybe_boolean, :maybe_sort]

        def on_maybe_projection(node)
          value, = *node.updated(nil, process_all(node))
          value
        end

        def on_request(node)
          process_all(node).inject({}) { |a, e| a.update(*e.children) }
        end

        def on_request_query(node)
          v, = *process(*node)
          node.updated(nil, [{ query: v }])
        end

        def on_request_projection(node)
          v, = *process_all(node)
          node.updated(nil, [{ projection: v.children.flatten }])
        end

        def on_object_type(node)
          v, = *node
          node.updated(nil, [{ objectType: v }])
        end
      end
    end
  end
end
