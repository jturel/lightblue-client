module Lightblue
  module Visitors
    class Hasher
      require 'json'
      include Lightblue::Visitor

      def to_json
        @hash.to_json
      end

      def data
        @hash
      end

      def visit_node_field(o)
        @hash = { o.key => o.field }
      end

      def visit_node_value(o)
        @hash = { rvalue:  o.value }
      end

      def visit_binop_eq(o, left, right)
        @hash = { op: '$eq' }.merge(left).merge(right)
      end

      def visit_nary_and(o, children)
        @hash = { '$and' => children }
      end

      def visit_nary_or(o, children)
        @hash = { '$or' => children }
      end

      def visit_nary_all(o, children)
        @hash = { '$all' => children }
      end

      def visit_node_query(o, root)
        @hash = root
      end
    end
  end
end
