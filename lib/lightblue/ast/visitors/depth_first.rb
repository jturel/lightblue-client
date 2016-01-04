module Lightblue
  module AST
    module Visitors
      class DepthFirst < Lightblue::AST::Visitor
        def initialize(&block)
          @in_order = []
          @pre_order = []
          @post_order = []
          instance_eval(&block) if block
        end

        def pre_order(mod)
          @pre_order << mod
        end

        def in_order(mod)
          @in_order << mod
        end

        def on_terminal(node)
          do_pre_order(node)
        end
        multi_alias :on_terminal, Lightblue::AST::Tokens::TERMINALS

        def handler_missing(node)
          puts "Handler Missing for: #{self.class} #{node}"
        end

        def on_query_array(node)
          node.updated(nil, process_all(node))
        end

        def on_union(node)
          traverse(node)
        end
        multi_alias :on_union, Lightblue::AST::Tokens::UNIONS.keys

        def on_expression(node)
          traverse(node)
        end

        multi_alias :on_expression, Lightblue::AST::Tokens::EXPRESSIONS.keys
        def traverse(node)
          node = node.updated(nil, do_pre_order(node))
          children = node.map do |child|
            child = process(child)
          end
          do_in_order(node.updated(nil, children))
        end

        def do_pre_order(node)
          @pre_order.inject(node) {|acc,m| m.process(acc) }
        end

        def do_in_order(node)
          @in_order.inject(node) {|acc,m| m.process(acc) }
        end
      end
    end
  end
end
