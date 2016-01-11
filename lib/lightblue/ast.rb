require 'ast'
require 'diffy'
require 'lightblue/ast/tokens'
require 'lightblue/ast/visitor'
require 'lightblue/ast/visitors/unfold_visitor'
require 'lightblue/ast/visitors/hash_visitor'
require 'lightblue/ast/visitors/validation_visitor'
module Lightblue
  module AST
    class Node < ::AST::Node
      include Enumerable

      def type?(t)
        type == t
      end

      def expression?
        Lightblue::AST::Tokens.node_is_expression?(self)
      end

      def terminal?
        Lightblue::AST::Tokens.node_is_terminal?(self)
      end

      def operator?
        Lightblue::AST::Tokens.node_is_operator?(self)
      end

      def union?
        Lightblue::AST::Tokens.node_is_union?(self)
      end

      def atom?
        Lightblue::AST::Tokens.node_is_atom?(self)
      end

      def each
        children.each { |child| yield(child) }
      end
    end

    module Sexp
      def s(type, *children)
        Lightblue::AST::Node.new(type, children)
      end
    end
  end
end
