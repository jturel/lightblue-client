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

          raise TooManyChildren if tail
          if !tokens.include?(child)
            raise InvalidToken, "Invalid token #{child} for #{node.type}. \
                                #{node.type}_operator can accept #{tokens}."
          end
          node
        end
        multi_alias(:on_operator, Lightblue::AST::Tokens::OPERATORS.keys)

        def on_union(node)
          tokens = Tokens::UNIONS[node.type]
          child, tail = *node
          raise MissingChild if !child
          raise TooManyChildren if tail
          if !tokens.include?(child.type)
            raise InvalidSubexpression,
                  "Invalid subexpression #{child.type} for #{node.type}_expression. \
                                #{node.type}_expression can accept #{tokens}."
          end
          node
        end
        multi_alias(:on_union, Lightblue::AST::Tokens::UNIONS.keys)

        def on_expression(node)
          parameters = Tokens::EXPRESSIONS[node.type].map(&:values).flatten

          raise MissingQueryParameter, node.map(&:type) - parameters unless node.map(&:type) == parameters
          node
        end
        multi_alias(:on_expression, Lightblue::AST::Tokens::EXPRESSIONS.keys)

        def on_field_or_array(node)
          raise InvalidTerminal, node if node.children.any?{|n| n.is_a?(AST::Node) }
          node
        end

        def on_boolean(node)
          value, _ = *node
          case value
          when TrueClass; node
          when FalseClass; node
          else raise AtomTypeMismatch, "Expected a TrueClass | FalseClass, got #{value}"
          end
        end

        def on_empty(node)
          child, _ = *node
          raise AtomTypeMismatch, "Expected nil, got #{child}" if !child.nil?
          node
        end

        def on_pattern(node)
          value, _ = *node
          case value
          when Regexp; node
          when String; node
          else
            raise AtomTypeMismatch, "Expected a Regexp | String, got #{value}"
          end
        end

        def on_value_list_array(node)
          children, _ = *node
          case children
          when Array; node
          else
            raise AtomTypeMismatch, "Expected an Array of Values, got #{node.children}"
          end
        end

        def on_field(node)
          child, _ = *node
          case child
          when String; node
          when Symbol; node
          else
            raise AtomTypeMismatch, "Expected a field, got #{node.children}"
          end
        end

        def on_array_field(node)
          child, _ = *node
          case child
          when String; node
          when Symbol; node
          else
            raise AtomTypeMismatch, "Expected a field, got #{node.children}"
          end
        end

        def on_value(node)
          child, tail = *node
          raise AtomTypeMismatch, "Expected a value, got a collection #{node.children}" if tail
          case child
          when Array
            raise AtomTypeMismatch, "Expected a value, got a collection #{node.children}"
          when Hash
            raise AtomTypeMismatch, "Expected a value, got a collection #{node.children}"
          when String || Symbol || TrueClass || FalseClass || FixNum || Float
            node
          end
        end

        def handler_missing(node)
          raise UnknownNode, node
        end
      end
    end
  end
end
