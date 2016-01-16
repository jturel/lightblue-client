module Lightblue
  module Expressions
    module Operators

      class BadParamOrdering < StandardError; end 
      module NaryLogical
        # @param [Symbol] token
        # @param [Expression] expression
        # @return [Expression]
        def nary_logical_operator(token, expression)

        end
        private :nary_logical_operator

        # @!macro op
        #   @param [Expression] expression
        #   @return [Expression] 
        def and(expression)
          nary_logical_operator(:$and, expression)
        end

        # @macro op
        def or(expression)
          nary_logical_operator(:$or, expression)
        end

        # @macro op
        def all(expression)
          nary_logical_operator(:$all, expression)
        end

        # @macro op
        def any(expression)
          nary_logical_operator(:$any, expression)
        end
      end

      module BinaryComparison
        # @abstract
        # @param [Symbol] token
        # @param [Expression] expression
        # @return [Expression]
        def binary_comparison_operator(token, expression)
        end

        # @macro op
        def eq(expression)
          binary_comparison_operator(:$eq, expression)
        end

        # @macro op
        def neq(expression)
          binary_comparison_operator(:$neq, expression)
        end

        # @macro op
        def lt(expression)
          binary_comparison_operator(:$lt, expression)
        end

        # @macro op
        def gt(expression)
          binary_comparison_operator(:$gt, expression)
        end

        # @macro op
        def lte(expression)
          binary_comparison_operator(:$lte, expression)
        end

        # @macro op
        def gte(expression)
          binary_comparison_operator(:$gte, expression)
        end
      end

      module UnaryLogical
       # @param [Symbol] token
       # @param [Expression] expression
       # @return [Expression]
       def unary_logical_operator(token, expression)

        end
        private :unary_logical_operator

        # @macro op
        def not(expression)
          unary_logical_operator(:$not, expression)
        end
      end

      module NaryComparison
        # @param [Symbol] token
        # @param [Expression] expression
        # @return [Expression]
        def nary_comparison_operator(token, expression)

        end
        private :nary_comparison_operator

        # @macro op
        def in(expression)
          nary_comparison_operator(:$in, expression)
        end

        # @macro op
        def not_in(expression)
          nary_comparison_operator(:$not_in, expression)
        end

        # @macro op
        def nin(expression)
          nary_comparison_operator(:$nin, expression)
        end
      end

      module ArrayComparison
        # @param [Symbol] token
        # @param [Expression] expression
        # @return [Expression]
        def array_comparison_operator(token, expression)

        end
        private :array_comparison_operator

        # @macro op
        def any(expression)
          array_comparison_operator(:$in, expression)
        end

        # @macro op
        def all(expression)
          array_comparison_operator(:$not_in, expression)
        end

        # @macro op
        def none(expression)
          array_comparison_operator(:$nin, expression)
        end
      end
    end
  end
end
