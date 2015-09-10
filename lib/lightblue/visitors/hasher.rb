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

      def visit_terminal(o)
        @hash = { o.token => o.value }
      end
      [
        :visit_node_value,
        :visit_node_field,
        :visit_node_valuearray
      ].each { |m| alias_method m, :visit_terminal }

      def visit_node_fieldarray(o, values)
        @hash = { o.token => values.map { |x| x.values[0] } }
      end

      def visit_binop_eq(_o, left, right)
        @hash = { op: '$eq' }.merge(left).merge(right)
      end

      def visit_nary_and(_o, children)
        @hash = { '$and' => children }
      end

      def visit_narycomp_in(_o, left, right)
        @hash = { op: '$in' }.merge(left).merge(right)
      end

      def visit_nary_or(_o, children)
        @hash = { '$or' => children }
      end

      def visit_nary_all(_o, children)
        @hash = { '$all' => children }
      end

      def visit_node_query(_o, root)
        @hash = root
      end
    end
  end
end
