require 'ast'
module Lightblue
  module AST
    module Visitors
      class Validation < Lightblue::AST::Visitor
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
        class AtomTypeMismatch < StandardError; end

        def on_operator(node)
          tokens = Tokens::OPERATORS[node.type]
          child, tail = *node

          fail TooManyChildren if tail
          unless tokens.include?(child)
            fail InvalidToken, "Invalid token #{child} for #{node.type}. \
                                #{node.type}_operator can accept #{tokens}."
          end
          node
        end
        multi_alias(:on_operator, Lightblue::AST::Tokens::OPERATORS.keys)

        def on_union(node)
          tokens = Tokens::UNIONS[node.type]
          child, tail = *node
          fail MissingChild unless child
          fail TooManyChildren if tail
          unless tokens.include?(child.type)
            fail InvalidSubexpression,
                 "Invalid subexpression #{child.type} for #{node.type}_expression. \
                                #{node.type}_expression can accept #{tokens}."
          end
          node
        end
        multi_alias(:on_union, Lightblue::AST::Tokens::UNIONS.keys)

        def on_expression(node)
          parameters = Tokens::EXPRESSIONS[node.type].map(&:values).flatten

          fail MissingQueryParameter, node.map(&:type) - parameters unless node.map(&:type) == parameters
          node
        end
        multi_alias(:on_expression, Lightblue::AST::Tokens::EXPRESSIONS.keys)

        def on_field_or_array(node)
          fail InvalidTerminal, node if node.children.any? { |n| n.is_a?(AST::Node) }
          node
        end

        def on_boolean(node)
          value, _tail = *node
          case value
          when TrueClass then node
          when FalseClass then node
          else
            fail AtomTypeMismatch, "Expected a TrueClass | FalseClass, got #{value}"
          end
        end

        def on_empty(node)
          child, _tail = *node
          fail AtomTypeMismatch, "Expected nil, got #{child}" if child
          node
        end

        def on_pattern(node)
          value, _tail = *node
          case value
          when Regexp then node
          when String then node
          else
            fail AtomTypeMismatch, "Expected a Regexp | String, got #{value}"
          end
        end

        def on_value_list_array(node)
          children, _tail = *node
          case children
          when Array then node
          else
            fail AtomTypeMismatch, "Expected an Array of Values, got #{node.children}"
          end
        end

        def on_field(node)
          child, _tail = *node
          case child
          when String then node
          when Symbol then node
          else
            fail AtomTypeMismatch, "Expected a field, got #{node.children}"
          end
        end

        def on_array_field(node)
          child, _tail = *node
          case child
          when String then node
          when Symbol then node
          else
            fail AtomTypeMismatch, "Expected a field, got #{node.children}"
          end
        end

        def on_value(node)
          child, tail = *node
          fail AtomTypeMismatch, "Expected a value, got a collection #{node.children}" if tail
          case child
          when Array
            fail AtomTypeMismatch, "Expected a value, got a collection #{node.children}"
          when Hash
            fail AtomTypeMismatch, "Expected a value, got a collection #{node.children}"
          else
            node
          end
        end

        def handler_missing(node)
          fail UnknownNode, node
        end
      end
    end
  end
end
