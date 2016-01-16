module Lightblue
  # The Expression class wraps and manipulates the AST for each expression type specified by Lightblue. It is the only class that should
  # operate directly on the AST.
  #
  # There is one expression subclass for each of the primary expressions specified by Lightblue: Search, Projection, Sort, and Update.
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
    # @param [AST::Node] ast
    def initialize(ast = ast_root)
      @ast = ast
    end

    protected

    # @abstract
    # @return [AST::Node]
    def self.ast_root
    end

    def ast_root
      self.class.ast_root
    end

    private
    def ast
      @ast
    end
    # !@group helpers
    # @param [Symbol] type
    # @param [Array] children
    def self.new_node(type, children)
      Lightblue::AST::Node.new(type, children)
    end

    def new_node(type, children)
      Lightblue::AST::Node.new(type, children)
    end
    # !@endgroup
  end
end
require 'lightblue/expressions/operators'
require 'lightblue/expressions/search'
require 'lightblue/expressions/update'
require 'lightblue/expressions/sort'
require 'lightblue/expressions/projection'

=begin
  class Expression

    attr_accessor :ast
    def initialize(ast = Lightblue::AST::Node
      @resolved = false
      @ast = []
    end

    @abstract
    def ast_root
    end
    def field(expression)
      @ast = @ast.concat([expression])
      self
    end

    def [](arg)
      field(Lightblue::AST::Node.new(:field, [arg]))
    end

    def resolved?
      @resolved
    end

    def apply_ast(ast)
      fail if @ast.any?
      @ast = Lightblue::AST::Visitors::UnfoldVisitor.new.process(ast)
      resolve
      self
    end

    def find(expression)
      case expression
      when Lightblue::Expression
        expression.dup
      when AST::Node
        @ast = expression.dup
        self
      end
    end

    def resolve
      return self if resolved? || !@ast
      Lightblue::AST::Tokens::EXPRESSIONS.each do |k, v|
        next if @ast.map(&:type) != v.map(&:values).flatten
        @ast = case @ast
               when Array then unfold_union(AST::Node.new(k, @ast))
               when AST::Node then unfold_union(@ast.updated(k, @ast.children))
               end
        @resolved = true
        break
      end
      self
    end

    def unfold_union(node)
      union = Lightblue::AST::Tokens::REVERSE_UNIONS[node.type]
      if union
        node = node.updated(union, [node])
        unfold_union(node)
      else
        node
      end
    end

    def nary_comparison_operator(token, expr)
      @ast = @ast.concat(
        [Lightblue::AST::Node.new(:nary_comparison_operator, [token]),
         evaluate_nary_rhs(expr)])
      resolve
      self
    end

    # TODO: Dynamically defining this stuff is icky
    Lightblue::AST::Tokens::OPERATORS[:nary_comparison_operator].each do |token|
      define_method(token.to_s.delete('$')) { |expr = nil| nary_comparison_operator(token, expr) }
    end

    def binary_comparison_operator(token, expr)
      @ast = @ast.concat(
        [Lightblue::AST::Node.new(:binary_comparison_operator, [token]),
         evaluate_binary_rhs(expr)])
      resolve
      self
    end

    def nary_logical_operator(token, expr = nil)
      @ast = AST::Node.new(:nary_logical_expression,
                           [
                             AST::Node.new(:nary_logical_operator, [token]),
                             AST::Node.new(:query_array,
                                           [@ast, expr.flatten.map(&:ast)].flatten)
                           ])
      resolve
      self
    end

    def unary_logical_operator(token, expr = nil)
      @ast = AST::Node.new(:unary_logical_expression,
                           [
                             AST::Node.new(:unary_logical_operator, [token]),
                             @ast, expr.ast
                           ].flatten
                          )
      resolve
      self
    end

    AST::Tokens::OPERATORS[:nary_logical_operator].each do |token|
      define_method(token.to_s.delete('$')) { |*expr| nary_logical_operator(token, expr) }
    end

    # TODO: Dynamically defining this stuff is icky
    Lightblue::AST::Tokens::OPERATORS[:binary_comparison_operator].each do |token|
      define_method(token.to_s.delete('$')) { |expr = nil| binary_comparison_operator(token, expr) }
    end

    def to_hash
      Lightblue::AST::Visitors::ValidationVisitor.new.process(ast)
      Lightblue::AST::Visitors::HashVisitor.new.process(ast).children[0]
    end

    private

    def evaluate_binary_rhs(expr)
      case expr
      when Lightblue::Expression then expr.ast.first
      when Lightblue::AST::Node then expr
      else
        Lightblue::AST::Node.new(:value, [expr])
      end
    end

    def evaluate_nary_rhs(expr)
      case expr
      when Lightblue::Expression
        expr.ast.first.updated(:array_field, expr.ast.first.children)
      when Lightblue::AST::Node then expr
      when Array
        Lightblue::AST::Node.new(:value_list_array, [expr])
      end
    end
  end
=end
