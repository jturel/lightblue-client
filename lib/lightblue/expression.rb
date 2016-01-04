module Lightblue
  class Expression
    attr_reader :ast, :finds
    def initialize
      @resolved = false
      @ast = []
    end

    def field(expression)
      @ast = @ast.concat([expression])
      self
    end

    def resolved?
      @resolved
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

    def evaluate_expression(expr)
      case expr
      when Fixnum || String || Symbol
        AST::Node.new(:value, [expr])
      when AST::Node
        expr
      when Field
        expr.ast.children
      when nil
      end
    end


    def resolve

      # noop if already resolved
      return self if resolved? || !@ast

      Lightblue::AST::Tokens::EXPRESSIONS.each do |k, v|
        break if resolved?
        if @ast.map(&:type) == v.map(&:values).flatten
          case @ast
          when Array
            @ast = AST::Node.new(k, @ast)
          when AST::Node
            @ast = @ast.updated(k, @ast.children)
          end
          @resolved = true
        end
      end
      self
    rescue => e
      binding.pry
    end

    def nary_comparison_operator(token, expr)
      @ast = @ast.concat([
                       Lightblue::AST::Node.new(:nary_comparison_operator, [token]),
                       evaluate_nary_rhs(expr)
                         ])
      resolve
      self
    end

    # TODO: Dynamically defining this stuff is icky
    Lightblue::AST::Tokens::OPERATORS[:nary_comparison_operator].each do |token|
      define_method(token.to_s.gsub('$','')) { |expr = nil| nary_comparison_operator(token, expr) }
    end

    def binary_comparison_operator(token, expr)
      @ast = @ast.concat([
                           Lightblue::AST::Node.new(:binary_comparison_operator, [token]),
                           evaluate_binary_rhs(expr)
                         ])
      resolve
      self
    end

    def nary_logical_operator(token, *expr)
      @ast = AST::Node.new(:nary_logical_expression,
                           [AST::Node.new(:nary_logical_operator, [token]),

                            AST::Node.new(:query_array, [
                                            @ast, expr.flatten.map(&:ast) ].flatten)
                           ]
                          )
      resolve
      self
    end

    def unary_logical_operator(token, expr = nil)
      @ast = AST::Node.new(:unary_logical_expression,
                           [
                             AST::Node.new(:unary_logical_operator, [token]),
                             @ast, expr.flatten.map(&:ast)
                           ].flatten
                          )
      resolve
      self

    end



    AST::Tokens::OPERATORS[:nary_logical_operator].each do |token|
      define_method(token.to_s.gsub('$','')) { |*expr| nary_logical_operator(token, expr) }
    end

    AST::Tokens::OPERATORS[:unary_logical_operator].each do |token|
      define_method(token.to_s.gsub('$','')) { |expr = nil| unary_logical_operator(token, expr) }
    end


    # TODO: Dynamically defining this stuff is icky
    Lightblue::AST::Tokens::OPERATORS[:binary_comparison_operator].each do |token|
      define_method(token.to_s.gsub('$','')) { |expr = nil| binary_comparison_operator(token, expr) }
    end

    private
    def evaluate_binary_rhs(expr)
      case expr
      when Lightblue::Expression
        expr.ast.first
      when Lightblue::AST::Node
        expr
      else
        Lightblue::AST::Node.new(:value, [expr])
      end
    end

    def evaluate_nary_rhs(expr)
      case expr
      when Lightblue::Expression
        expr.ast.first.updated(:array_field, expr.ast.first.children)
      when Lightblue::AST::Node
        expr
      when Array
        Lightblue::AST::Node.new(:value_list_array, [expr])
      else
        binding.pry
      end
    end


  end
end
