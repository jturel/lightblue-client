require 'ast'
require 'diffy'
require 'lightblue/ast/tokens'
require 'lightblue/ast/visitor'
require 'lightblue/ast/visitors/unfold_visitor'
require 'lightblue/ast/visitors/hash_visitor'
require 'lightblue/ast/visitors/validation'
module Lightblue
  module AST
    def self.pretty_diff(l, r)
      l = "Expected:\n" + l.to_sexp + "\n"
      r = "Actual:\n" + r.to_sexp + "\n"
      diff = Diffy::SplitDiff.new(l, r, format: :color)
      width =[diff.left, diff.right].map do |x|
        x.split("\n").max_by(&:size).to_s.size
      end.max
      str = ''
      ([diff.left.lines.count, diff.right.lines.count].max).times do |i|

        l = diff.left.lines[i].to_s
        r = diff.right.lines[i].to_s
        l = l.gsub("\n", '')
        r = r.gsub("\n",'')
        w = " " * (width - l.size + 10)
        str << "#{l}#{w}#{r}\n"
      end
      str
    end

    class Node < ::AST::Node
      include Enumerable
      attr_reader :root
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
        children.each {|x| yield(x) }
      end

      def select_child(type)
        children.select{|c| c.respond_to?(:type) && c.type == type }.first
      end

      def replace(sym, args = [])
        n = select_child(sym)
      end
   end
    module Sexp
      def s(type, *children)
        Lightblue::AST::Node.new(type, children)
      end
    end
  end
end
