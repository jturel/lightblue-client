require 'ast'
module Lightblue
  module AST
    module Visitors
      class ValidationVisitor < Lightblue::AST::Visitor
        class TooManyChildren < StandardError; end
        class InvalidToken < StandardError; end
        class InvalidLiteralType < StandardError; end
        class InvalidTerminal < StandardError; end
        class InvalidSubexpression < StandardError; end
        class MissingQueryParameter < StandardError; end
        class InvalidQueryParameter < StandardError; end
        class BadParameterOrdering < StandardError; end
        class UnknownNode < StandardError; end
        class MissingChild < StandardError; end
        class TerminalTypeMismatch < StandardError; end
        class InvalidRange < StandardError; end

        def on_operator(node)
          tokens = Tokens::OPERATORS[node.type]
          child, tail = *node

          raise TooManyChildren if tail
          unless tokens.include?(child)
            raise InvalidToken, "Invalid token #{child} for #{node.type}. \
                                #{node.type}_operator can accept #{tokens}."
          end
          node
        end
        handle_with :on_operator, Lightblue::AST::Tokens::OPERATORS.keys

        def on_union(node)
          tokens = Tokens::UNIONS[node.type]
          child, tail = *node
          raise MissingChild, "#{node.type} passed with no children" unless child
          raise TooManyChildren if tail
          unless tokens.include?(child.type)
            raise InvalidSubexpression,
                  "Invalid subexpression #{child.type} for #{node.type}_expression. \
                                #{node.type}_expression can accept #{tokens}."
          end
          process_all(node)
          nil
        end
        handle_with :on_union, Lightblue::AST::Tokens::UNIONS.keys

        def on_maybe_boolean(node)
          child, = *node
          case child.type
          when :boolean then process_all node
          when :empty then process_all node
          else
            raise InvalidSubexpression, "Expected Boolean | Empty, got #{child.type}"
          end
          nil
        end

        def on_maybe_projection(node)
          child, = *node
          case child.type
          when :projection then process_all node
          when :empty then process_all node
          else
            raise InvalidSubexpression, "Expected Projection | Empty, got #{child.type}"
          end
          nil
        end

        def on_maybe_sort(node)
          child, = *node
          case child.type
          when :sort then process_all node
          when :empty then process_all node
          else
            raise InvalidSubexpression, "Expected Sort | Empty, got #{child.type}"
          end
          nil
        end

        def on_expression(node)
          parameters = Tokens::EXPRESSIONS[node.type].map(&:values).flatten
          if node.map(&:type) != parameters
            msg = "Expected Parameters: #{parameters}, got: #{node.map(&:type)}"
            raise MissingQueryParameter, msg
          end
          process_all(node)
          nil
        end
        handle_with :on_expression, Lightblue::AST::Tokens::EXPRESSIONS.keys

        def on_field_or_array(node)
          raise InvalidTerminal, node if node.children.any? { |n| n.is_a?(AST::Node) }
          process_all node
          nil
        end

        def on_boolean(node)
          value, = *node
          case value
          when TrueClass
          when FalseClass
          else
            raise TerminalTypeMismatch, "Expected a TrueClass | FalseClass, got #{value}"
          end
          nil
        end

        def on_empty(node)
          child, = *node
          raise TerminalTypeMismatch, "Expected nil, got #{child}" if child
          process_all node
          nil
        end

        def on_pattern(node)
          value, = *node
          case value
          when Regexp
          when String
          when Symbol
          else
            raise TerminalTypeMismatch, "Expected a Regexp | String, got #{value}"
          end
          nil
        end

        def on_value_list_array(node)
          children, = *node
          case children
          when Array
          else
            raise TerminalTypeMismatch, "Expected an Array of Values, got #{node.children}"
          end
          nil
        end

        def on_field(node)
          child, = *node
          case child
          when String
          when Symbol
          else
            raise TerminalTypeMismatch, "Expected a field, got #{node.children}"
          end
          nil
        end

        def on_array_field(node)
          child, = *node
          case child
          when String
          when Symbol
          else
            raise TerminalTypeMismatch, "Expected a field, got #{node.children}"
          end
          nil
        end

        def on_value(node)
          child, tail = *node
          raise TerminalTypeMismatch, "Expected a value, got a collection #{node.children}" if tail
          case child
          when Array
            raise TerminalTypeMismatch, "Expected a value, got a collection #{node.children}"
          when Hash
            raise TerminalTypeMismatch, "Expected a value, got a collection #{node.children}"
          end
          nil
        end

        def on_query_array(node)
          invalid = node.reject do |child|
            [:query_expression, :nary_logical_expression, :unary_logical_expression].include? child.type
          end
          raise TerminalTypeMismatch, invalid if invalid.any?
          process_all(node)
          nil
        end

        def on_basic_projection_array(node)
        end

        def on_range(node)
          child, = *node
          raise InvalidRange if child.length > 2
          a, b = *child
          raise InvalidRange if a > b
          nil
        end

        def handler_missing(node)
          raise UnknownNode, node
        end
      end
    end
  end
end
