module Lightblue
  module AST
    class Visitor < ::AST::Processor

      def self.multi_alias(meth, method_arr)
        method_arr.each { |m| alias_method("on_#{m}", meth) }
      end

    end
  end
end
