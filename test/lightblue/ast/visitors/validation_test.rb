require 'test_helper'
class TestValidation < Minitest::Test
  include AstHelper

  Validation = Lightblue::AST::Visitors::Validation
  def setup
    @processor = Lightblue::AST::Visitors::Validation.new
  end

  def test_nary_field_relational_expression_throws_on_missing_parameters_1
    exp = s(:nary_field_relational_expression,
            s(:field, :foo),
            s(:array_field, :bar))
    assert_raises(Validation::MissingQueryParameter) { @processor.process exp }
  end

  def test_nary_field_relational_expression_throws_on_missing_parameters_2
    exp = s(:nary_field_relational_expression,
            s(:nary_comparison_operator, :$in),
            s(:array_field, :bar))
    assert_raises(Validation::MissingQueryParameter) { @processor.process exp }
  end

  def test_nary_field_relational_expression_throws_on_missing_parameters_3
    exp = s(:nary_field_relational_expression,
            s(:nary_comparison_operator, :$in),
            s(:field, :bar))
    assert_raises(Validation::MissingQueryParameter) { @processor.process exp }
  end

  def expression_accepts_valid_token(expression, token)
    exp = s(expression, token)
    assert_ast_equal exp, @processor.process(exp)
  end

  def expression_throws_error_on_invalid_subexpression(expression)
    op = s(expression, s(:nary_field_relational_expression))
    assert_raises(Validation::InvalidSubexpression) { @processor.process(op) }
  end

  def expression_throws_error_on_too_many_children(expression)
    op = s(expression, :$not, :$bar)
    assert_raises(Validation::TooManyChildren) { @processor.process(op) }
  end

  def test_nary_field_relational_expression_accepts_valid_parameters
    exp = s(:nary_field_relational_expression,
            s(:field, :foo),
            s(:nary_comparison_operator, :$in),
            s(:array_field, :bar))
    @processor.process(exp)
  end

  def test_nary_comparison_operator_accepts_valid_token
    operator_accepts_valid_token(:nary_comparison_operator, :$nin)
  end

  def test_nary_comparison_operator_throws_error_on_invalid_token
    operator_throws_error_on_invalid_token(:nary_comparison_operator)
  end

  def test_nary_comparison_operator_throws_error_on_too_many_children
    operator_throws_error_on_too_many_children(:nary_comparison_operator)
  end

  def test_binary_comparison_operator_accepts_valid_token
    operator_accepts_valid_token(:binary_comparison_operator, :"=")
  end

  def test_binary_comparison_operator_throws_error_on_invalid_token
    operator_throws_error_on_invalid_token(:binary_comparison_operator)
  end

  def test_binary_comparison_operator_throws_error_on_too_many_children
    operator_throws_error_on_too_many_children(:binary_comparison_operator)
  end

  def test_nary_logical_operator_accepts_valid_token
    operator_accepts_valid_token(:nary_logical_operator, :$or)
  end

  def test_nary_logical_operator_throws_error_on_invalid_token
    operator_throws_error_on_invalid_token(:nary_logical_operator)
  end

  def test_nary_logical_operator_throws_error_on_too_many_children
    operator_throws_error_on_too_many_children(:nary_logical_operator)
  end

  def test_unary_logical_operator_accepts_valid_token
    operator_accepts_valid_token(:unary_logical_operator, :$not)
  end

  def test_unary_logical_operator_throws_error_on_invalid_token
    operator_throws_error_on_invalid_token(:unary_logical_operator)
  end

  def test_unary_logical_operator_throws_error_on_too_many_children
    operator_throws_error_on_too_many_children(:unary_logical_operator)
  end

  def operator_accepts_valid_token(operator, token)
    exp = s(operator, token)
    assert_ast_equal exp, @processor.process(exp)
  end

  def operator_throws_error_on_invalid_token(operator)
    op = s(operator, :$invalid)
    assert_raises(Validation::InvalidToken) { @processor.process(op) }
  end

  def operator_throws_error_on_too_many_children(operator)
    op = s(operator, :$not, :$bar)
    assert_raises(Validation::TooManyChildren) { @processor.process(op) }
  end

  def test_query_expression_accepts_valid_subexpressions
    expression_accepts_valid_token(:query_expression, s(:comparison_expression))
    expression_accepts_valid_token(:query_expression, s(:logical_expression))
  end

  def test_query_expression_throws_error_on_invalid_subexpression
    expression_throws_error_on_invalid_subexpression(:query_expression)
  end

  def test_query_expression_throws_error_on_too_many_children
    expression_throws_error_on_too_many_children(:query_expression)
  end

  def test_comparison_expression_accepts_valid_subexpressions
    expression_accepts_valid_token(:comparison_expression, s(:relational_expression))
    expression_accepts_valid_token(:comparison_expression, s(:array_comparison_expression))
  end

  def test_comparison_expression_throws_error_on_invalid_subexpression
    expression_throws_error_on_invalid_subexpression(:comparison_expression)
  end

  def test_comparison_expression_throws_error_on_too_many_children
    expression_throws_error_on_too_many_children(:comparison_expression)
  end

  def test_relational_expression_accepts_valid_subexpressions
    expression_accepts_valid_token(:relational_expression, s(:binary_relational_expression))
    expression_accepts_valid_token(:relational_expression, s(:nary_relational_expression))
    expression_accepts_valid_token(:relational_expression, s(:regex_match_expression))
  end

  def test_relational_expression_throws_error_on_invalid_subexpression
    expression_throws_error_on_invalid_subexpression(:relational_expression)
  end

  def test_relational_expression_throws_error_on_too_many_children
    expression_throws_error_on_too_many_children(:relational_expression)
  end

  def test_binary_relational_expression_accepts_valid_subexpressions
    expression_accepts_valid_token(:binary_relational_expression, s(:field_comparison_expression))
    expression_accepts_valid_token(:binary_relational_expression, s(:value_comparison_expression))
  end

  def test_binary_relational_expression_throws_error_on_invalid_subexpression
    expression_throws_error_on_invalid_subexpression(:binary_relational_expression)
  end

  def test_binary_relational_expression_throws_error_on_too_many_children
    expression_throws_error_on_too_many_children(:binary_relational_expression)
  end

  def test_logical_expression_accepts_valid_subexpressions
    expression_accepts_valid_token(:logical_expression, s(:unary_logical_expression))
    expression_accepts_valid_token(:logical_expression, s(:nary_logical_expression))
  end

  def test_logical_expression_throws_error_on_invalid_subexpression
    expression_throws_error_on_invalid_subexpression(:logical_expression)
  end

  def test_logical_expression_throws_error_on_too_many_children
    expression_throws_error_on_too_many_children(:logical_expression)
  end

  def atom_throws_error_on_invalid_value(atom)
    assert_raises(Validation::AtomTypeMismatch, atom) { @processor.process(atom) }
  end

  def atom_accepts_valid_values(atom)
    assert_ast_equal(atom, @processor.process(atom))
  end

  def test_boolean_throws_error_on_invalid_value
    atom_throws_error_on_invalid_value(s(:boolean, 'string'))
  end

  def test_boolean_accepts_boolean_values
    atom_accepts_valid_values(s(:boolean, true))
    atom_accepts_valid_values(s(:boolean, false))
  end

  def test_boolean_throws_error_on_nil
    atom_throws_error_on_invalid_value(s(:boolean))
  end

  def test_pattern_throws_error_on_invalid_value
    atom_throws_error_on_invalid_value(s(:pattern, 1))
    atom_throws_error_on_invalid_value(s(:pattern, true))
    atom_throws_error_on_invalid_value(s(:pattern, [:bar]))
  end

  def test_pattern_accepts_regex_values
    atom_accepts_valid_values(s(:pattern, /foo/))
    atom_accepts_valid_values(s(:pattern, 'foo'))
  end

  def test_value_list_array_throws_error_on_invalid_value
    atom_throws_error_on_invalid_value(s(:value_list_array, 1))
    atom_throws_error_on_invalid_value(s(:value_list_array, 'foo'))
  end

  def test_value_list_array_accepts_value_list
    atom_accepts_valid_values(s(:value_list_array, [1, 2, 3]))
    atom_accepts_valid_values(s(:value_list_array, %w(1, 2, 3)))
  end

  def test_array_field_throws_error_on_invalid_value
    atom_throws_error_on_invalid_value(s(:value_list_array, s(:atom, :foo), s(:atom, :foo)))
    atom_throws_error_on_invalid_value(s(:value_list_array, 1))
    atom_throws_error_on_invalid_value(s(:value_list_array, 'foo'))
  end

  def test_array_field_accepts_array_field
    atom_accepts_valid_values(s(:array_field, :one))
    atom_accepts_valid_values(s(:array_field, 'one'))
  end

  def test_field_throws_error_on_invalid_value
    atom_throws_error_on_invalid_value(s(:field, [1, 2, 3]))
    atom_throws_error_on_invalid_value(s(:field, 1))
  end

  def test_field_accepts_field
    atom_accepts_valid_values(s(:field, 'foo'))
    atom_accepts_valid_values(s(:field, :bar))
  end

  def test_field_throws_error_on_invalid_values
    atom_throws_error_on_invalid_value(s(:field, [1, 2, 3]))
    atom_throws_error_on_invalid_value(s(:field, 1))
  end
end
