module Lightblue
  module Expressions
    module Errors
      class BadParamForOperator < StandardError
        def initialize(token, argument)
          super "Got invalid RHS argument: #{argument} of class: #{argument.class} for operator: #{token}."
        end
      end
    end
  end
end
