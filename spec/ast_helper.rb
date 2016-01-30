require 'spec_helper'
require './lib/lightblue/ast'
# rubocop:disable Metrics/AbcSize
# rubocop:disable Metrics/MethodLength
module AstHelper
  include Lightblue::AST::Sexp

  def self.included(klass)
    klass.send(:extend, self)
  end

  def value_node(value)
    new_node(:value, [value])
  end

  def new_node(type, children)
    Lightblue::AST::Node.new(type, children)
  end

  def assert_ast_equal(exp, act, msg = nil)
    msg = msg ? "#{msg}\n\n" : "\n"
    diff = AstHelper.pretty_diff(exp, act)
    expect(exp).to eq(act)
  end

  def assert_ast_produces_hash(exp, ast)
    expanded = Lightblue::AST::Visitors::UnfoldVisitor.new.process(ast)
    act = Lightblue::AST::Visitors::HashVisitor.new.process(expanded)
    children, = *act
    assert_equal exp, children, expanded.to_sexp
  end

  def self.pretty_diff(l, r)
    l = "Expected:\n" + l.to_sexp + "\n"
    r = "Actual:\n" + r.to_sexp + "\n"
    diff = Diffy::SplitDiff.new(l, r, format: :color)
    width = [diff.left, diff.right].map { |x| x.split("\n").max_by(&:size).to_s.size }.max
    str = ''
    [diff.left.lines.count, diff.right.lines.count].max.times do |i|
      l = diff.left.lines.to_a[i].to_s.delete("\n")
      r = diff.right.lines.to_a[i].to_s.delete("\n")
      w = ' ' * (width - l.size + 10)
      str << "#{l}#{w}#{r}\n"
    end
    str
  end

  def use_ast_node_helpers
    let(:field_node) { s(:field, :bar) }
    let(:rfield_node) { s(:field, :batz) }
    let(:binary_op_node) { s(:binary_comparison_operator, :!=) }
    let(:nary_op_node) { s(:nary_comparison_operator, :$in) }
    let(:array_contains_op_node) { s(:array_contains_operator, :$none) }
    let(:values_node) { s(:value_list_array, [1, 2, 3]) }
    let(:sym_values_node) { s(:value_list_array, [:foo, :bar]) }
    let(:pattern_node) { s(:pattern, /foo/) }

    let(:array_field_node) { s(:array_field, :foo) }
    let(:field_comparison_exp_node) { s(:field_comparison_expression, field_node, binary_op_node, rfield_node) }
    let(:value_comparison_exp_node) { s(:value_comparison_expression, field_node, binary_op_node, value_node) }

    let(:binary_exp_node) { s(:binary_relational_expression, field_comparison_exp_node) }

    let(:relational_exp_node) { s(:relational_expression, binary_exp_node) }
    let(:array_contains_exp_node) do
      s(:array_contains_expression,
        s(:array_field, :foo),
        array_contains_op_node,
        values_node)
    end

    let(:array_relational_exp_node) { s(:array_comparison_expression, array_contains_exp_node) }

    let(:nary_field_relational_exp_node) do
      s(:nary_value_relational_expression,
        field_node,
        nary_op_node,
        values_node)
    end
    let(:comparison_exp_node) { s(:comparison_expression, relational_exp_node) }

    let(:regex_match_exp_node) do
      s(:regex_match_expression,
        s(:field, :foo),
        s(:pattern, /.*ss12/),
        s(:maybe_boolean, s(:empty, nil)),
        s(:maybe_boolean, s(:empty, nil)),
        s(:maybe_boolean, s(:boolean, true)),
        s(:maybe_boolean, s(:empty, nil)))
    end

    let(:unary_logical_exp_node) do
      s(:unary_logical_expression,
        s(:unary_logical_operator, :$not),
        s(:query_expression, comparison_exp_node))
    end

    let(:query_exp_node) { s(:query_expression, comparison_exp_node) }

    let(:nary_logical_exp_node) do
      s(:nary_logical_expression,
        s(:nary_logical_operator, :$and),
        s(:query_array,
          s(:query_expression, comparison_exp_node)))
    end
    let(:nary_relational_exp_node) { s(:nary_relational_expression, nary_field_relational_exp_node) }
    let(:unresolved_exp_node) { s(:unresolved_expression, field_node, binary_op_node, rfield_node) }

    let(:logical_exp_node) { s(:logical_expression, nary_logical_exp_node) }

    let(:field_projection_node) do
      s(:field_projection,
        s(:pattern, :foo),
        s(:maybe_boolean, s(:empty, nil)),
        s(:maybe_boolean, s(:empty, nil)))
    end

    let(:projection_node) { s(:projection, s(:basic_projection, field_projection_node)) }

    let(:array_match_projection_node) do
      s(:array_match_projection,
        s(:pattern, :foo),
        s(:boolean, true),
        query_exp_node,
        s(:maybe_projection, projection_node),
        s(:maybe_sort, s(:empty, nil)))
    end
  end
end
