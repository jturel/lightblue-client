module Lightblue
  module Visitors
    # Performs a depth first tree traversal, yielding
    # each node to a block. Node#each is currently implemented
    # with this class. (Therefore, calling Node#each will perform a depth first
    # traversal of the tree).

    class Traverse
      include ::Lightblue::Visitor

      def visit_terminal o
        yield o
      end

      [ :visit_node_value,
        :visit_node_field,
        :visit_node_valuearray
      ]. each { |m| alias_method m, :visit_terminal }

      def visit_node_fieldarray o, &blk
        yield o, o.value.map { |f| visit f, &blk }
      end

      def visit_node_query o, &blk
        yield o, visit(o.root, &blk)
      end

      def visit_unary_not o, &blk
        yield o, visit(o.root)
      end

      def visit_nary o, &blk
        yield o, o.children.map { |child| visit child, &blk }
      end

      [
       :visit_nary_or,
       :visit_nary_and,
       :visit_nary_all,
       :visit_nary_any
      ].each { |m| alias_method m, :visit_nary }

      def visit_nary_comp o, &blk
        yield o, visit(o.left, &blk), visit(o.right, &blk)
      end
      [
       :visit_narycomp_in,
       :visit_narycomp_nin,
       :visit_narycomp_not_in
      ].each { |m| alias_method m, :visit_nary_comp }

      def visit_binop_eq o, &blk
        yield o, visit(o.left, &blk), visit(o.right, &blk)
      end
    end
  end
end
