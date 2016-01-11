require 'test_helper'
require 'ast_helper'

describe 'Visitor' do
  extend AstHelper
  use_ast_node_helpers
  let(:query1) do
    s(:query_expression,
      s(:comparison_expression,
        s(:relational_expression,
          s(:binary_relational_expression,
            s(:field_comparison_expression,
              s(:field, :foo),
              s(:binary_comparison_operator, :$eq),
              s(:field, 'asdf'))))))
  end

  let(:query2) do
    s(:query_expression,
      s(:comparison_expression,
        s(:relational_expression,
          s(:regex_match_expression,
            s(:field, :foo),
            s(:pattern, /.*ss12/),
            false,
            nil,
            nil,
            true
           ))))
  end
  let(:query3) do
    s(:query_expression,
      s(:comparison_expression,
        s(:relational_expression,
          s(:nary_relational_expression,
            s(:nary_value_relational_expression,
              s(:field, :foo),
              s(:nary_comparison_operator, :$in),
              s(:value_list_array, [1, 2, 3, 4]))))))
  end

  let(:nested_query) do
    s(:query_expression,
      s(:logical_expression,
        s(:nary_logical_expression,
          s(:nary_logical_operator, :$or),
          s(:query_array, query1, query2, query3)
         )))
  end

  let(:visitor) do
    Lightblue::AST::Visitors::HashVisitor.new
  end

  describe :value_comparison_expression do
    before { @subject = :value_comparison_expression }
    it 'evaluates properly' do
      ast = s(@subject, field_node, binary_op_node, value_node)
      exp = { field: :bar, op: :!=, rvalue: 1 }
      assert_ast_produces_hash(exp, ast)
    end
  end

  describe '' do
    before { @subject = :nary_value_relational_expression }

    it 'evaluates properly' do
      ast = s(@subject, field_node, nary_op_node, sym_values_node)

      exp = { field: :bar, op: :$in, values: [:foo, :bar] }
      assert_ast_produces_hash(exp, ast)
    end
  end

  describe :regex_match_expression do
    it 'allows missing defaults' do
      ast = s(:regex_match_expression, :foo, /foo/, nil, nil, true, nil)
      exp = { field: :foo, regex: /foo/, dotall: true }
      assert_ast_produces_hash(exp, ast)
    end
  end

  describe :array_contains_expression do
    it 'allows missing defaults' do
      ast = s(:array_contains_expression, array_field_node, array_contains_op_node, values_node)
      exp = { array: :foo, contains: :$none, values: [1, 2, 3] }
      assert_ast_produces_hash(exp, ast)
    end
  end

  describe 'projections' do
    it 'field projections' do
      ast = s(:projection,
              s(:basic_projection,
                s(:field_projection,
                  'foo',
                  false,
                  true)))
      assert_ast_produces_hash({ field: 'foo', include: false, recursive: true }, ast)
    end

    it 'array projections' do
      ast = s(:projection,
              s(:basic_projection,
                s(:array_projection,
                  s(:array_match_projection,
                    'foo',
                    false,
                    nested_query
                   ))))

      exp = { field: 'foo',
              include: false,
              match: {
                :$or => [
                  { field: :foo, op: :$eq, rfield: 'asdf' },
                  { field: :foo, regex: /.*ss12/, extended: false, caseInsensitive: true },
                  { field: :foo, op: :$in, values: [1, 2, 3, 4] }
                ]
              }
            }
      assert_ast_produces_hash(exp, ast)
    end
  end

  describe :full_queries do
    it 'works' do
      literal = {
        :$or => [
          { field: :foo, op: :$eq, rfield: 'asdf' },
          { field: :foo, regex: /.*ss12/, extended: false, caseInsensitive: true },
          { field: :foo, op: :$in, values: [1, 2, 3, 4] }
        ]
      }
      assert_ast_produces_hash(literal, nested_query)
    end
  end
end
