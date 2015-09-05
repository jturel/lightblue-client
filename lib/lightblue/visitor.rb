module Lightblue
  # Since Ruby can't do type based method overloading, the visitor pattern is a little bit different.
  # Instead of the traditional pattern of defining VisitorSubclass#visit(foo : TypeOfFoo),
  # we define VisitorSubclass#visit_class_of_foo.
  #
  # Each visited object must define "name_for_visitor" which returns the string value used to
  # dynamically invoke the visit implementation for foo_class on the visitor. I will be refactoring
  # this in terms of accept. e.g., InstanceOfNode#accept(visitor) will call visitor.visit(node.name_for_visitor)

  module Visitor

    class VisitorError < StandardError; end

    module ClassMethods

      # I stole this from Arel. It's basically just for optimization. Since it's not really optimizing
      # much, it's probably unnecessary complexity.
      def dispatch_hash
        @@dispatch_hash ||= Hash.new do |h, k|
          h[k] = format('visit_%s', k.name_for_visitor )
        end
      end

    end

    module InstanceMethods
      def visit node, *args, &blk
        dispatch(node, *args, &blk)
      end

      def dispatch(node, *args, &blk)
        meth = self.class.dispatch_hash[node.class]
        send meth, node, *args, &blk
      rescue NoMethodError => e
        if e.name =~ /^visit_/
          raise VisitorError, "#{self} cannot visit #{node.class.name}, #{meth} undefined"
        else
          raise e
        end
      end
    end

    def self.included(klass)
      klass.extend ClassMethods
      klass.send(:include, InstanceMethods)
    end
  end
end
