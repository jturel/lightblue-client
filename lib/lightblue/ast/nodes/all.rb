module Lightblue
  module AST

    # Need to differentiate operators/expressions
    module Nodes

      class Unary < Lightblue::AST::Node
        def initialize(*args)
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
          @right = right.kind_of?(Field) ? right.set_rfield : Value.new(right)
        end
      end

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

      class Query < Lightblue::AST::Node

        attr_reader :root

        def initialize(query)
          @root = query
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
