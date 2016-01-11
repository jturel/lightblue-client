require 'test_helper'
require './lib/lightblue/ast'
module AstHelper
  include Lightblue::AST::Sexp

  def assert_ast_equal(exp, act, msg = nil)
    msg = msg ? "#{msg}\n\n" : "\n"
    diff = Lightblue::AST.pretty_diff(exp, act)
    assert exp == act, "#{msg}#{diff}"
  end

  def assert_ast_produces_hash(exp, ast, msg = nil)
    msg = msg ? "#{msg}\n\n" : "\n"
    expanded = Lightblue::AST::Visitors::UnfoldVisitor.new.process(ast)
    act = Lightblue::AST::Visitors::HashVisitor.new.process(expanded)
    children, _ = *act
    assert_equal exp, children, expanded.to_sexp
  end

  def use_ast_node_helpers
    let(:field_node) { s(:field, :bar) }
    let(:rfield_node) { s(:field, :batz) }
    let(:binary_op_node) { s(:binary_comparison_operator, :!= ) }
    let(:nary_op_node) { s(:nary_comparison_operator, :$in ) }
    let(:array_contains_op_node) { s(:array_contains_operator, :$none ) }
    let(:value_node) { s(:value, 1) }
    let(:values_node) { s(:value_list_array, [1,2,3]) }
    let(:sym_values_node) { s(:value_list_array, [:foo, :bar]) }
    let(:pattern_node) { s(:pattern, /foo/) }

    let(:array_field_node) { s(:array_field, :foo) }
    let(:field_comparison_exp_node) { s(:field_comparison_expression, field_node, binary_op_node, rfield_node) }
    let(:value_comparison_exp_node) { s(:value_comparison_expression, field_node, binary_op_node, value_node) }

    let(:binary_exp_node) do
      s(:binary_relational_expression, field_comparison_exp_node)
    end

    let(:relational_exp_node) { s(:relational_expression, binary_exp_node) }
    let(:array_contains_exp_node) { s(:array_contains_expression,
                                      s(:array_field, :foo),
                                      array_contains_op_node,
                                      values_node) }

    let(:array_relational_exp_node) { s(:array_comparison_expression, array_contains_exp_node) }

    let(:nary_field_relational_exp_node) { s(:nary_value_relational_expression,
                                             field_node,
                                             nary_op_node,
                                             values_node)
    }
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
    let(:nary_relational_exp_node) { s(:nary_relational_expression, nary_field_relational_exp_node)}
    let(:unresolved_exp_node) { s(:unresolved_expression, field_node, binary_op_node, rfield_node) }

    let(:logical_exp_node) { s(:logical_expression, nary_logical_exp_node) }

    let(:field_projection_node) do
      s(:field_projection,
        s(:pattern, :foo),
        s(:maybe_boolean, s(:empty, nil)),
        s(:maybe_boolean, s(:empty,  nil)))
    end

    let(:projection_node) do
      s(:projection,
        s(:basic_projection, field_projection_node))
    end

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
