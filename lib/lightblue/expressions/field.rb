require 'lightblue/expression'
module Lightblue
  module Expressions
    class Field < Expression
      def initialize(name)
        super new_node(:field, [name])
      end
    end
  end
end
