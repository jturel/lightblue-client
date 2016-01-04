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
    act = visitor.process(ast)
    children, _ = *act
    assert_equal exp, children
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
    let(:field_comparison_expression_node) { s(:field_comparison_expression, field_node, binary_op_node, rfield_node) }
    let(:binary_exp_node) { s(:binary_relational_expression,
                              field_comparison_expression_node) }
    let(:unresolved_exp_node) { s(:unresolved_expression, field_node, binary_op_node, rfield_node) }
  end
end
