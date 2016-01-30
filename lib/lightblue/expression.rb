require 'lightblue/expressions/errors'
require 'lightblue/expressions/operators'
module Lightblue
  # The Expression class wraps and manipulates the AST for each expression type specified by Lightblue. It is the only class that should
  # operate directly on the AST.
  #
  # There is one expression subclass for each of the primary expressions specified by Lightblue: Query, Projection, Sort, and Update.
  #
  # Expressions are meant to be used in two ways:
  #   - Instantiated directly by the user, so they may be used and reused to compose a larger query or queries.
  #   - Insantiated by the Query/Manager DSLs, which then composes them them into a query. The difference is that the builder/DSL
  #     syntax makes it more difficult to expose the Expression for reuse at a later time.them to build a query.
  #
  # Expressions generally expose methods corresponding to the operators and terminals defined under the Lightblue spec.
  # However, other methods might be useful. These methods must return a new instance of Expression instantiated with the tranformed AST.
  #
  # @abstract
  class Expression
    Errors = Expressions::Errors

    def initialize(ast)
      @ast = ast
      freeze
    end

    def ast
      @ast
    end
    protected :ast

    # !@group helpers

    # @param [Symbol] type
    # @param [Array] children
    def self.new_node(type, children)
      AST::Node.new(type, children)
    end
    private_class_method :new_node

    def new_node(type, children)
      AST::Node.new(type, children)
    end
    private :new_node

    def literal_to_node(literal)
      case literal
      when Fixnum then new_node(:value, [literal])
      when String then new_node(:value, [literal])
      when Symbol then new_node(:value, [literal])
      when Array then new_node(:value_list_array, [literal])
      end
    end
    private :literal_to_node

    def literal_to_expression(literal)
      klass.new(literal_to_node(literal))
    end
    private :literal_to_expression

    # !@endgroup

    def klass
      self.class
    end
  end
end
require 'lightblue/expressions/unbound'
require 'lightblue/expressions/field'
require 'lightblue/expressions/query'
require 'lightblue/expressions/update'
require 'lightblue/expressions/sort'
require 'lightblue/expressions/projection'
