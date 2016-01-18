require 'ast'
require 'diffy'
require 'lightblue/ast/tokens'
require 'lightblue/ast/visitor'
require 'lightblue/ast/visitors/unfold_visitor'
require 'lightblue/ast/visitors/hash_visitor'
require 'lightblue/ast/visitors/validation_visitor'
module Lightblue
  module AST
    def self.unfold(ast)
      Lightblue::AST::Visitors::UnfoldVisitor.new.process(ast)
    end

    def self.valid?(ast)
      Lightblue::AST::Visitors::ValidationVisitor.new.process(unfold(ast))
    end
 
    class Node < ::AST::Node
      include Enumerable
      def each
        children.each { |child| yield(child) }
      end

      def terminal?
        Lightblue::AST::Tokens::TERMINALS.include?(type)
      end

   end

    module Sexp
      def s(type, *children)
        Lightblue::AST::Node.new(type, children)
      end
    end
  end
end
