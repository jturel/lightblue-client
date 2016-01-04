module Lightblue
  module AST
    module Visitors
      class HashVisitor < Lightblue::AST::Visitor
        def on_union(node)
          child, _ = *node
          literal, _ = *child
          node.updated(nil, [literal])
        end
        multi_alias :on_union, Lightblue::AST::Tokens::UNIONS.keys

        def on_expression(node)
          fields = Lightblue::AST::Tokens::EXPRESSIONS[node.type].map(&:keys).flatten
          hash = {}
          node.each_with_index  do |child, index|
            if child.terminal? || child.none? { |c| c.is_a? AST::Node }
              #noop
            else
              child = process(child)
            end
            next if child.nil? || child.first.nil?
            hash[fields[index]], _ = *child
          end
          node.updated(nil, [hash])
        end
        multi_alias :on_expression, Lightblue::AST::Tokens::EXPRESSIONS.keys

        def on_nary_logical_expression(node)
          op, children = *process_all(node)
          node.updated(nil, [{ op => children.map(&:children).flatten }])
        end

        def on_terminals(node)
          value, tail = *node
          value
        end
        multi_alias :on_terminals, Lightblue::AST::Tokens::TERMINALS
      end
    end
  end
end
