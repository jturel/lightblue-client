module Lightblue
  module Expressions
    module Operators
      module NaryLogical
        # @param [Symbol] token
        # @param [Array<Expression>, Expression] expression
        # @return [Expression]
        def nary_logical_operator(token, expression)

        end
        private :nary_logical_operator

        # @param [Array<Expression>, Expression] expression
        # @return [Expression]
        def and(expression)
          nary_logical_operator(:$and, expression)
        end

        # @param [Array<Expression>, Expression] expression
        # @return [Expression]
        def or(expression)
          nary_logical_operator($or, expression)
        end


        # @param [Array<Expression>, Expression] expression
        # @return [Expression]
        def all(expression)
          nary_logical_operator($all, expression)
        end

        # @param [Array<Expression>, Expression] expression
        # @return [Expression]
        def any(expression)
          nary_logical_operator($any, expression)
        end
      end

      module BinaryComparison
        # @param [Symbol] token
        # @param [Expression] expression
        # @return [Expression]
        def binary_comparison_operator(token, expression)

        end
        private :binary_comparison_operator

        # @!macro op
        #   @param [Expression] expression
        #   @return [Expression]
        def eq(expression)
          binary_comparison_operator($eq, expression)
        end

        # @macro op
        def neq(expression)
          binary_comparison_operator($neq, expression)
        end

        # @macro op
        def lt(expression)
          binary_comparison_operator($lt, expression)
        end

        # @macro op
        def gt(expression)
          binary_comparison_operator($gt, expression)
        end

        # @macro op
        def lte(expression)
          binary_comparison_operator($lte, expression)
        end

        # @macro op
        def gte(expression)
          binary_comparison_operator($gte, expression)
        end
      end

      module UnaryLogical
        # @param [Symbol] token
        # @param [Expression] expression
        # @return [Expression]
        def unary_logical_operator(token, expression)

        end
        private :unary_logical_operator

        # @param [Expression] expression
        # @return [Expression]
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

        def in(expression)
          nary_comparison_operator($in, expression)
        end

        def not_in(expression)
          nary_comparison_operator($not_in, expression)
        end

        def nin(expression)
          nary_comparison_operator($nin, expression)
        end
      end

      module ArrayNary
        # @param [Symbol] token
        # @param [Expression] expression
        # @return [Expression]
        def nary_comparison_operator(token, expression)

        end
        private :nary_comparison_operator

        def in(expression)
          nary_comparison_operator($in, expression)
        end

        def not_in(expression)
          nary_comparison_operator($not_in, expression)
        end

        def nin(expression)
          nary_comparison_operator($nin, expression)
        end
      end
    end
  end
end
