module Lightblue
  module Visitors
    # Performs a depth first tree traversal, yielding
    # each node to a block. Node#each is currently implemented
    # with this class. (Therefore, calling Node#each will perform a depth first
    # traversal of the tree).

    class Traverse
      include Lightblue::Visitor

      def visit_node_field(o)
        yield o
      end

      def visit_node_value(o)
        yield o
      end

      def visit_node_query(o, &blk)
        yield o, visit(o.root, &blk)
      end

      def visit_unary_not(o)
        yield o, visit(o.root)
      end

      def visit_nary(o, &blk)
        yield o, o.children.map { |child| visit child, &blk }
      end

      alias_method :visit_nary_or, :visit_nary
      alias_method :visit_nary_and, :visit_nary
      alias_method :visit_nary_all, :visit_nary
      alias_method :visit_nary_any, :visit_nary

      def visit_binop_eq(o, &blk)
        yield o, visit(o.left, &blk), visit(o.right, &blk)
      end
    end
  end
end
