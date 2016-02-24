module Lightblue
  # A lot of this needs to get moved to the FindManager
  # This class should handle operations on the AST
  class Expression
    attr_accessor :ast
    def initialize
      @resolved = false
      @ast = []
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

    def match(expression)
      empty = AST::Node.new(:maybe_boolean, [AST::Node.new(:empty, [nil])])
      @ast = Lightblue::AST::Node.new(:regex_match_expression,
                                      [@ast.first,
                                       AST::Node.new(:pattern, [expression]),
                                       empty, empty, empty, empty])
      resolve
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
end
