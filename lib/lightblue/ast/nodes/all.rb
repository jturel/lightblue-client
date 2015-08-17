module Lightblue
  module AST
    # All of the nodes are currently defined in here. Need to make better use of inheritence.
    # Ideally, a visitor should be able to visit_nary, but currently, it has to visit_nary_(operator)

    # I forsee having a handful of abstract subclasses of node, each with tons and tons of concrete classes
    # that mostly only implement to_s

    # It may also be worth creating abstract Operator and Expression classes, which Operators and Expressions can
    # implement. Either way, we need to define which abstract node classes we expect.

    module Nodes
      class Query < Lightblue::AST::Node
        # Query is the root node. Calling entity#where returns a query node, which can then be used to construct
        # the ast. We should remove it in favor of provding a wrapper that tracks the root node,
        # as well as controls access to the underlying ast.
        # (all of the constructor methods are currently defined in the Node parent class, which needs to change)
        attr_reader :root

        def initialize(query)
          @root = query
        end
      end

      class Unary < Lightblue::AST::Node
        def initialize(*)
        end
      end

      class Nary < Lightblue::AST::Node
        attr_reader :children

        def initialize(left, *args)
          @children = ([left] + args).flatten
        end
      end

      class BinOp < Lightblue::AST::Node
        attr_reader :left, :right

        def initialize(left, right)
          @left = left
          @right = right.respond_to?(:set_rfield) ? right.set_rfield : Value.new(right)
        end
      end

      # TODO: These classes don't need to be dynamic defined. This is purely to save typing for now.
      [:Eq].each do |klass|
        const_set(klass.to_s, Class.new(BinOp))
      end

      [:And, :Or, :All, :Any].each do |klass|
        const_set(klass.to_s, Class.new(Nary))
      end

      [:Not].each do |klass|
        const_set(klass.to_s, Class.new(Unary))
      end

      class Field < Lightblue::AST::Node
        extend Lightblue::AST::HasNodes
        has_nodes :eq

        attr_reader :key, :field

        def initialize(field)
          @field = field
          @key = :field
        end

        def set_rfield
          @key = :rfield
          self
        end
      end

      class Value < Lightblue::AST::Node
        attr_reader :value

        def initialize(value)
          @value = value
        end
      end
    end
  end
end
