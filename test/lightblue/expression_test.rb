require 'test_helper'
require 'ast_helper'
include AstHelper
Expression = Lightblue::Expression
describe 'Expressions' do
  let(:expression) { Lightblue::Expression.new }
  let(:entity) { Lightblue::Entity.new(:foo) }
  let(:bin_expr) { entity[:bar].eq(:foo).resolve }
  let(:bin_expr2) { entity[:grep].lt(:sed).resolve }

  use_ast_node_helpers

  it 'find' do
    actual = expression.find(bin_expr)
    assert_ast_equal s(:query_expression,
                       s(:comparison_expression,
                         s(:relational_expression,
                           s(:binary_relational_expression,
                             s(:value_comparison_expression,
                               s(:field, :bar),
                               s(:binary_comparison_operator, :$eq),
                               s(:value, :foo)))))), actual.ast
  end

  describe 'nary expressions' do
    it 'with single sub expressions' do
      actual = expression.and(bin_expr)
      expected =
        s(:query_expression,
          s(:logical_expression,
            s(:nary_logical_expression,
              s(:nary_logical_operator, :$and),
              s(:query_array, bin_expr.resolve.ast))))
      assert_ast_equal expected, actual.ast
    end

    it 'chaining' do
      actual = expression.find(bin_expr).and(bin_expr2)
      expected = s(:nary_logical_expression,
                   s(:nary_logical_operator, :$and),
                   s(:query_array, bin_expr.ast, bin_expr2.ast))
      assert_ast_equal expected, actual.ast
    end

    it 'more chaining' do
      actual = expression.find(bin_expr).and(bin_expr2).or(bin_expr)
      expected = s(:nary_logical_expression,
                   s(:nary_logical_operator, :$or),
                   s(:query_array,
                     s(:nary_logical_expression,
                       s(:nary_logical_operator, :$and),
                       s(:query_array, bin_expr.ast, bin_expr2.ast)),
                     bin_expr.ast))
      assert_ast_equal expected, actual.ast
    end

    it 'with multiple sub expressions' do
      actual = expression.and(bin_expr, bin_expr2)
      expected = s(:query_expression,
                   s(:logical_expression,
                     s(:nary_logical_expression,
                       s(:nary_logical_operator, :$and),
                       s(:query_array, bin_expr.ast, bin_expr2.ast))))

      assert_ast_equal expected, actual.ast
    end

    it 'chaining with subexprs' do
      actual = expression.and(bin_expr, bin_expr2).or(bin_expr)
      expected = s(:nary_logical_expression,
                   s(:nary_logical_operator, :$or),
                   s(:query_array,
                     s(:query_expression,
                       s(:logical_expression,
                         s(:nary_logical_expression,
                           s(:nary_logical_operator, :$and),
                           s(:query_array, bin_expr.ast, bin_expr2.ast)))),
                     bin_expr.ast))
      assert_ast_equal expected, actual.ast
    end
  end
end
