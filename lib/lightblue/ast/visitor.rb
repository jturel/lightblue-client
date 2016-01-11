module Lightblue
  module AST
    class Visitor < ::AST::Processor
      def self.handle_with(meth, method_arr)
        method_arr.each { |m| alias_method("on_#{m}", meth) }
      end
    end
  end
end
