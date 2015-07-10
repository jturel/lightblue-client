module Lightblue
  module AST
    class Node
      include Enumerable

      def each
        Lightblue::Visitors::Traverse.new.visit(self) do |node, *args|
          yield(node, *args)
        end
      end

      def self.visitor_prefix
        ancestors[1].to_s.split('::').last.downcase + '_%s'
      end

      def self.visitor_name
        format(visitor_prefix, name.split('::').last.downcase)
      end

      def any *right
        Nodes::Any.new(self, right)
      end

      def all *right
        Nodes::All.new(self, right)
      end

      def or *right
        Nodes::Or.new(self, right)
      end

      def and *right
        Nodes::And.new(self, right)
      end
      alias_method :where, :and

      def build
        hasher = Lightblue::Visitors::Hasher.new
        each do |node, *args|
          hasher.visit(node, *args)
        end
        hasher.data
      end

      def to_json
        build.to_json
      end
    end
  end
end
